(defpackage #:ultralisp/widgets/version
  (:use #:cl)
  (:import-from #:weblocks/widget
                #:render
                #:defwidget)
  (:import-from #:ultralisp/models/version
                #:get-version-by-number)
  (:import-from #:ultralisp/models/check
                #:get-changelog)
  (:import-from #:cl-ppcre
                #:all-matches-as-strings)
  (:import-from #:ultralisp/widgets/not-found
                #:page-not-found)
  (:export
   #:make-version-widget))
(in-package ultralisp/widgets/version)


(defwidget version ()
  ())


(defmethod render ((widget version))
  (let* ((path (weblocks/request:get-path))
         (version-number (first (all-matches-as-strings "\\d+" path)))
         (version (when version-number
                    (get-version-by-number version-number))))
    (unless version
      (page-not-found))
    
    (let ((changelog (string-trim (list #\Newline #\Space #\Tab)
                                  (get-changelog version)))
          (dist-url (format nil
                            "~A~A/~A/distinfo.txt"
                            (ultralisp/variables:get-base-url)
                            (ultralisp/variables:get-dist-name)
                            version-number)))
      (weblocks/html:with-html
        (:h3 ("Version ~A" version-number))
        
        (when changelog
          (:h4 "Built because:")
          (:pre changelog))
        
        (:h4 "To install:")
        (:pre (format nil "(ql-dist:install-dist \"~A\"
                      :prompt nil)" dist-url))
        (:p ("or if you are using the [Qlot](https://github.com/fukamachi/qlot), then add these lines into your <code>qlfile</code>:"))
        (:pre (format nil "dist ultralisp ~A
ultralisp :all :latest"
                      dist-url))
        (:p ("and run <code>qlot update</code> in the shell."))
        ))))


(defun make-version-widget ()
  (make-instance 'version))