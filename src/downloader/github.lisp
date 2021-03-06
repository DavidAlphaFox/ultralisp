(defpackage #:ultralisp/downloader/github
  (:use #:cl)
  (:import-from #:legit)
  (:import-from #:ultralisp/models/project
                #:update-and-enable-project
                #:get-last-seen-commit
                #:project)
  (:import-from #:ultralisp/models/check
                #:get-processed-at
                #:get-description)
  (:import-from #:ultralisp/downloader/base
                #:downloaded-project-path
                #:download
                #:make-downloader)
  (:import-from #:named-readtables
                #:in-readtable)
  (:import-from #:mito
                #:save-dao)
  (:import-from #:uiop
                #:ensure-directory-pathname)
  (:import-from #:ultralisp/utils
                #:ensure-absolute-dirname))
(in-package ultralisp/downloader/github)
(in-readtable :interpol-syntax)


(defun git-clone-or-update (url dir &key commit)
  (let* ((absolute-dir (ensure-absolute-dirname dir))
         (repo (legit:init absolute-dir
                           :remote url
                           :if-does-not-exist :clone)))
    ;; Here we are suppressing output from the git binary
    (with-output-to-string (*standard-output*)
      (let ((current-commit (legit:current-commit repo)))
        (when (or (not commit)
                  (not (string-equal commit
                                     current-commit)))
          (legit:pull repo)

          (when commit
            (legit:checkout repo commit)))))
    
    ;; return repository so that other actions could be performed on it
    (values repo)))


(defmethod make-downloader ((source (eql :github)))
  (lambda (base-dir &key user-or-org project last-seen-commit latest &allow-other-keys)
    (let* ((url (format nil "https://github.com/~A/~A.git"
                        user-or-org
                        project))
           (dir (ensure-directory-pathname
                 (merge-pathnames (format nil "~A-~A" user-or-org
                                          project)
                                  (ensure-directory-pathname base-dir))))
           (repo (git-clone-or-update url
                                      dir
                                      :commit (unless latest
                                                last-seen-commit))))
      
      (let ((current-commit (legit:current-commit repo)))
        (values dir
                (list :last-seen-commit
                      current-commit))))))
