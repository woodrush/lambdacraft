(defvar defmacro (macro (name args &rest body)
  `(defvar ,name (macro ,args ,@body))))

(defmacro defun (name args &rest body)
  `(setq ,name (lambda ,args ,@body)))

(defvar cond (macro (a &rest b)
  (if a
    `(if ,(car a)
      ,(car (cdr a))
      (cond ,@b))
    nil)))

(defmacro . (instance accesor)
  `(,instance ',accesor))

(defmacro new (&rest args)
  `((lambda (instance)
      ((. instance __init__) ,@(cdr args))      
      instance)
    (,(car args))))

(defmacro build-getter (args)
  (defun helper (args)
    (if args
      `(if (eq a ',(car args))
          ,(car args)
          ,(helper (cdr args)))
      nil))
  `(lambda (a) ,(helper args)))

(defmacro build-setter (args)
  (defun helper (args)
    (if args
      `(if (eq key ',(car args))
          (setq ,(car args) value)
          ,(helper (cdr args)))
      nil))
  `(lambda (key value) ,(helper args)))

(defmacro let* (binding &rest body)
  (defun helper (args)
    (if args
      `(let (,(car args)) ,(helper (cdr args)))
      `(progn ,@body)))
  (helper binding))

(defmacro defclass (name &rest body)
  (defun collect-fieldnames (args)
    (if args
      (cons (if (eq (car (car args)) 'defmethod)
              (car (cdr (car args)))
              (car (car args)))
            (collect-fieldnames (cdr args)))
      nil))
  (defun parse-body (body)
    (if body
      (cons (if (eq (car (car body)) 'defmethod)
              `(,(car (cdr (car body)))
                  (lambda ,(car (cdr (cdr (car body))))
                    ,@(cdr (cdr (cdr (car body))))))
              (car body))
            (parse-body (cdr body)))
      nil))
  (setq fieldnames (collect-fieldnames body))
  `(defun ,name ()
      (let* ((self ())
             (setter ())
              ,@(parse-body body))
        (setq setter (build-setter ,fieldnames))
        (setq self (build-getter ,fieldnames)))))

(defmacro setfield (name value)
  `(setter ',name ,value))

(defclass counter
  (i ())
  (c ())
  (defmethod __init__ (c)
    (setfield c c))
  (defmethod inc ()
    (setfield i (cons c (. self i))))
  (defmethod dec ()
    (cond
      ((. self i)
        (setfield i (cdr i)))
      (t
        (. self i))))
  (defmethod set-to (i)
    (setfield i i)))


(defvar counter1 (new counter (quote a)))
(defvar counter2 (new counter (quote b)))

((. counter1 inc))
((. counter2 inc))
((. counter1 inc))
((. counter1 dec))
((. counter1 inc))
((. counter1 inc))

((. counter1 set-to) '(a a a a a a a a a a))
((. counter2 set-to) '(b b))

((. counter2 inc))
((. counter2 inc))
((. counter1 inc))
((. counter2 dec))
((. counter1 inc))
((. counter2 inc))
((. counter2 inc))
