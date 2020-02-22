(DEFSYSTEM "app-deps" :CLASS :PACKAGE-INFERRED-SYSTEM :DEPENDS-ON
 ("3bmd" "alexandria" "anaphora" "babel" "babel-streams" "bordeaux-threads"
  "cffi" "chanl" "chipz" "chunga" "circular-streams" "cl+ssl" "cl-annot"
  "cl-arrows" "cl-base64" "cl-change-case" "cl-containers" "cl-cookie"
  "cl-cron" "cl-dbi" "cl-fad" "cl-gearman" "cl-inflector" "cl-interpol"
  "cl-markdown" "cl-mustache" "cl-postgres" "cl-ppcre" "cl-ppcre-unicode"
  "cl-reexport" "cl-store" "cl-strings" "cl-syntax" "cl-syntax-annot"
  "cl-unicode" "cl-unicode/base" "cl-utilities" "cl-yandex-metrika" "clack"
  "clack-socket" "closer-mop" "closure-common" "cxml" "cxml/dom" "cxml/klacks"
  "cxml/test" "cxml/xml" "dbi" "defmain" "defmain/defmain" "dexador" "dissect"
  "documentation-utils" "drakma" "dynamic-classes" "esrap" "external-program"
  "f-underscore" "fare-quasiquote" "fare-quasiquote-extras"
  "fare-quasiquote-optima" "fare-quasiquote-readtable" "fare-utils" "fast-http"
  "fast-io" "flamegraph" "flamegraph/core" "flexi-streams" "function-cache"
  "global-vars" "http-body" "introspect-environment" "ironclad" "iterate"
  "jonathan" "kebab" "lack" "lack-component" "lack-middleware-backtrace"
  "lack-middleware-mito" "lack-middleware-session" "lack-request"
  "lack-response" "lack-util" "lambda-fiddle" "lass" "legit" "lev"
  "link-header" "link-header/core" "lisp-namespace" "local-time"
  "local-time-duration" "log4cl" "log4cl-json" "lparallel" "mailgun"
  "mailgun/core" "md5" "metabang-bind" "metacopy" "metatilities"
  "metatilities-base" "mito" "mito-core" "mito-migration" "moptilities"
  "named-readtables" "net.didierverna.clon" "net.didierverna.clon.core"
  "net.didierverna.clon.setup" "optima" "parenscript" "parse-declarations-1.0"
  "parse-number" "proc-parse" "prometheus" "prometheus.collectors.process"
  "prometheus.collectors.sbcl" "prometheus.formats.text" "puri" "qlot"
  "qlot/errors" "qlot/install" "qlot/install/quicklisp" "qlot/logger"
  "qlot/main" "qlot/parser" "qlot/proxy" "qlot/server" "qlot/source"
  "qlot/source/base" "qlot/source/dist" "qlot/source/git" "qlot/source/github"
  "qlot/source/http" "qlot/source/ql" "qlot/source/ultralisp" "qlot/utils"
  "qlot/utils/asdf" "qlot/utils/ql" "qlot/utils/shell" "qlot/utils/tmp"
  "quantile-estimator" "quickdist" "quicklisp" "quri" "routes" "rutils"
  "salza2" "sb-sprof" "serapeum" "simple-inferiors" "slynk" "smart-buffer"
  "spinneret" "spinneret/cl-markdown" "split-sequence" "static-vectors" "str"
  "string-case" "swap-bytes" "sxql" "symbol-munger" "trivia"
  "trivia.balland2006" "trivia.level0" "trivia.level1" "trivia.level2"
  "trivia.quasiquote" "trivia.trivial" "trivial-backtrace" "trivial-cltl2"
  "trivial-features" "trivial-file-size" "trivial-garbage"
  "trivial-gray-streams" "trivial-indent" "trivial-macroexpand-all"
  "trivial-mimes" "trivial-timeout" "trivial-types" "trivial-utf-8" "type-i"
  "uiop" "usocket" "uuid" "vom" "weblocks-auth/auth" "weblocks-auth/button"
  "weblocks-auth/conditions" "weblocks-auth/core" "weblocks-auth/github"
  "weblocks-auth/models" "weblocks-auth/utils" "weblocks-file-server"
  "weblocks-file-server/core" "weblocks-lass" "weblocks-lass/core"
  "weblocks-navigation-widget" "weblocks-navigation-widget/core"
  "weblocks-parenscript" "weblocks-parenscript/weblocks-parenscript"
  "weblocks-ui" "weblocks-ui/core" "weblocks-ui/form" "weblocks/actions"
  "weblocks/app" "weblocks/app-actions" "weblocks/app-dependencies"
  "weblocks/app-mop" "weblocks/commands" "weblocks/debug"
  "weblocks/dependencies" "weblocks/error-handler" "weblocks/hooks"
  "weblocks/html" "weblocks/js" "weblocks/js/base" "weblocks/js/jquery"
  "weblocks/linguistic/grammar" "weblocks/page" "weblocks/request"
  "weblocks/request-handler" "weblocks/response" "weblocks/routes"
  "weblocks/server" "weblocks/session" "weblocks/session-lock"
  "weblocks/session-reset" "weblocks/utils/i18n" "weblocks/utils/list"
  "weblocks/utils/misc" "weblocks/utils/string" "weblocks/utils/timing"
  "weblocks/utils/uri" "weblocks/utils/warn" "weblocks/variables"
  "weblocks/widget" "weblocks/widgets/base" "weblocks/widgets/dom"
  "weblocks/widgets/mop" "weblocks/widgets/render-methods"
  "weblocks/widgets/root" "woo" "xsubseq" "zs3"))