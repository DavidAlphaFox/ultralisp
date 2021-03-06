(defpackage #:ultralisp/models/check
  (:use #:cl)
  (:import-from #:ultralisp/models/project
                #:get-name
                #:project)
  (:import-from #:mito
                #:retrieve-by-sql
                #:includes
                #:count-dao
                #:save-dao
                #:select-dao
                #:dao-table-class)
  (:import-from #:sxql
                #:from
                #:make-sql-symbol
                #:select
                #:left-join
                #:where
                #:order-by)
  (:import-from #:ultralisp/models/version
                #:make-version
                #:version)
  (:import-from #:alexandria
                #:make-keyword)
  (:import-from #:anaphora
                #:acond
                #:it)
  (:export
   #:get-project-checks
   #:make-added-project-check
   #:make-via-webhook-check
   #:make-via-cron-check
   #:base-check
   #:get-project
   #:project-has-changes-p
   #:get-description
   #:get-type
   #:get-check
   #:get-pending-checks
   #:get-processed-at
   #:get-checks
   #:get-error
   #:get-all-checks
   #:get-check-by-id
   #:any-check
   #:get-processed-in
   #:get-last-project-check
   #:get-pending-checks-count
   #:get-pending-checks-for-disabled-projects
   #:get-pending-checks-for-disabled-projects-count))
(in-package ultralisp/models/check)


(defparameter *allowed-check-types*
  '(:added-project :via-cron :via-webhook))


(defclass any-check ()
  ())


(defmacro defcheck (name)
  (let ((class-name (intern
                     (string-upcase
                      (format nil "~A-check"
                              name))))
        (make-func-name (intern
                         (string-upcase
                          (format nil "make-~A-check"
                                  name))))
        (check-type (make-keyword name)))
    `(progn
       (export ',class-name)
       (defclass ,class-name (any-check)
         ((type :col-type (or :text :null)
                :initarg :type
                :initform nil
                :reader get-type
                :documentation "Should be one of :added-project :via-webhook :via-cron"
                :inflate (lambda (text)
                           (make-keyword (string-upcase text)))
                :deflate #'symbol-name)
          (project :col-type project
                   :initarg :project
                   :documentation "A link to a project to be checked."
                   :reader get-project)
          (processed-at :col-type (or :timestamptz :null)
                        :initarg :processed-at
                        :initform nil
                        :accessor get-processed-at
                        :documentation "Date and time a check was finished at.")
          (processed-in :col-type (or :float :null)
                        :initarg :processed-in
                        :initform nil
                        :accessor get-processed-in
                        :documentation "Number of seconds required to process this check.")
          (error :col-type (or :text :null)
                 :initarg :error
                 :initform nil
                 :accessor get-error
                 :documentation "A error description. If processed-at is not null and error is nil,
                                 then check is considered as successful."))
         (:table-name "check")
         (:metaclass dao-table-class))

       
       (defmethod print-object ((check ,class-name) stream)
         (print-unreadable-object (check stream :type t)
           (format stream "~A~@[ ~A~]"
                   (get-name (get-project check))
                   (when (slot-boundp check 'processed-at)
                     (get-processed-at check)))))


       (defun ,make-func-name (project)
         "Creates or gets a check for the project.

          As a second value, returns `t' if check was created, or nil
          if it already existed in the database."
         (check-type project project)
         (let ((type ,check-type))
           (log:info "Triggering a check for" project type)
           
           (unless (member type *allowed-check-types*)
             (let ((*print-case* :downcase))
               (error "Unable to create check of type ~S"
                      type)))

           (acond
             ((get-project-checks project :pending t)
              (log:warn "Check already exists")
              (values (first it) nil))
             (t (values (mito:create-dao ',class-name
                                         :project project
                                         :type type)
                        t))))))))


(defcheck base)
(defcheck added-project)
(defcheck via-webhook)
(defcheck via-cron)


(defmethod get-error :around (check)
  (unless (get-processed-at check)
    (error "This check wasn't processed yet.")))


(defun upgrade-type (check)
  (when check
    (let* ((type (get-type check))
           (real-type (case type
                        (:added-project 'added-project-check)
                        (:via-webhook 'via-webhook-check)
                        (:via-cron 'via-cron-check))))
      (if real-type
          (change-class check real-type)
          check))))


(defun upgrade-types (checks)
  (mapcar #'upgrade-type checks))


(defun get-pending-checks (&key limit)
  (upgrade-types
   (select-dao 'base-check
     (includes 'project)
     (left-join 'project
                     :on (:= 'check.project_id
                             'project.id))
     (where (:is-null 'processed-at))
     (when limit
       (sxql:limit limit)))))

(defun cancel-pending-cron-checks ()
  (loop for check in (select-dao 'base-check
                       (where (:and (:is-null 'processed-at)
                                    (:= 'type "VIA-CRON"))))
        do (setf (get-processed-at check) (local-time:now)
                 (get-processed-in check) 0)
           (save-dao check)))

(defun get-pending-checks-count ()
  (let ((sql (select ((:as (:count :*)
                       :count))
               (from (make-sql-symbol (mito.dao::table-name (mito.util:ensure-class 'base-check))))
               (left-join 'project
                          :on (:= 'check.project_id
                                  'project.id))
               (where (:and (:is-null 'processed_at)
                       :project.enabled)))))
    (getf (first (retrieve-by-sql sql))
          :count)))


(defun get-pending-checks-for-disabled-projects (&key limit)
  (upgrade-types
   (select-dao 'base-check
     (includes 'project)
     (left-join 'project
                     :on (:= 'check.project_id
                             'project.id))
     (where (:and (:is-null 'processed-at)
                  (:not :project.enabled)))
     (when limit
       (sxql:limit limit)))))

(defun get-pending-checks-for-disabled-projects-count ()
  (let ((sql (select ((:as (:count :*)
                       :count))
               (from (make-sql-symbol (mito.dao::table-name (mito.util:ensure-class 'base-check))))
               (left-join 'project
                          :on (:= 'check.project_id
                                  'project.id))
               (where (:and (:is-null 'processed_at)
                            (:not :project.enabled))))))
    (getf (first (retrieve-by-sql sql))
          :count)))

(defun get-all-checks ()
  (upgrade-types
   (select-dao 'base-check)))


(defun get-check-by-id (id)
  (upgrade-type
   (mito:find-dao 'base-check
                  :id id)))


(defun get-checks (version)
  (check-type version version)
  (upgrade-types
   (mito:retrieve-dao 'base-check
                      :version version)))


(defun get-project-checks (project &key pending)
  (check-type project project)
  (upgrade-types
   (if pending
       (select-dao 'base-check
         (where (:and (:is-null 'processed-at)
                      (:= 'project-id (mito:object-id project)))))
       (mito:retrieve-dao 'base-check
                          :project project))))


(defun get-last-project-check (project)
  "Returns a last perofrmed check"
  (check-type project project)
  (upgrade-type
   (first
    (select-dao 'base-check
      (where (:and (:not (:is-null 'processed-at))
                   (:= 'project-id (mito:object-id project))))
      (order-by (:desc 'processed-at))))))
