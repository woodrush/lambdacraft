(defparameter lazy-env (make-hash-table :test #'equal))

(defmacro lazy-error (&rest message)
  `(error (concatenate 'string "Lazy K CL Error: " ,@message)))

(defmacro def-lazy (name expr)
  (cond ((not (atom name)) (lazy-error (format nil "Variable name ~a must be a symbol" (write-to-string name)))))
  `(setf (gethash ',name lazy-env) ',expr))

(defmacro defun-lazy (name args expr)
  (cond ((not (atom name)) (lazy-error (format nil "Function name ~a must be a symbol" (write-to-string name))))
        ((atom args)       (lazy-error (format nil "Argument list ~a must be a list in ~a"
                                       (write-to-string args) (write-to-string name)))))
  `(setf (gethash ',name lazy-env) '(lambda ,args ,expr)))

(defun macroexpand-lazy (expr)
  (cond ((atom expr)
         (let ((rexpr (gethash expr lazy-env `***lazy-cl-nomatch***)))
              (cond ((eq rexpr `***lazy-cl-nomatch***) expr)
                    (t (macroexpand-lazy rexpr)))))
        (t (mapcar #'macroexpand-lazy expr))))

(print (subst `aa `f `(f g h)))
(print (gethash 'f lazy-env))
(print (macroexpand-lazy `(f g h a c a)))


(defun curry (expr)
  (labels
    ((normalize-app (ret l)
       (cond ((not l) ret)
             (t (normalize-app (list ret (curry (car l))) (cdr l)))))
     (curry-lambda (args body)
       (cond ((= 1 (length args)) `(lambda ,args ,(curry body)))
             (t `(lambda (,(car args)) ,(curry-lambda (cdr args) body))))))
    (cond ((atom expr) expr)
          ((eq (car expr) `lambda) (curry-lambda (car (cdr expr)) (cdr (cdr expr))))
          ((eq 1 (length expr)) (curry (car expr)))
          (t (normalize-app (curry (car expr)) (cdr expr))))))

(print (curry `(a b (lambda (x y) x) d e f)))
(print (curry `(a b (c d e f (a b c d e) g) f g)))
(print (curry `(lambda (x y z) (x y ((a b c) x)))))
(print (curry `(lambda (x y z) (x y ((x y z) x)))))


(defun to-de-bruijn (body env)
  (labels
    ((lookup (env var)
       (let ((i (position var env)))
         (if i (+ 1 i) (concatenate `string "[" (write-to-string var) "]")))))
    (if (not (atom body))
        (if (and (atom (car body)) (eq (car body) `lambda))
            `(abs ,@(to-de-bruijn (car (cdr (cdr body))) (cons (car (car (cdr body))) env)))
            `(app ,@(to-de-bruijn (car body) env) ,@(to-de-bruijn (car (cdr body)) env)))
        (list (lookup env body)))))

(print (to-de-bruijn (curry `(lambda (x y z) (x y ((x y z) x)))) ()))

(defun to-blc-string (body)
  (labels
   ((int2varname (n)
      (if (> n 0) (concatenate `string "1" (int2varname (- n 1))) "0"))
    (token2string (token)
      (cond ((not token) "")
            ((eq token 'abs) "00")
            ((eq token 'app) "01")
            ((stringp token) token)
            (t (int2varname token)))))
   (if (not body) "" (concatenate `string (token2string (car body)) (to-blc-string (cdr body))))))


(defun compile-to-blc (expr)
  (to-blc-string (to-de-bruijn (curry (macroexpand-lazy expr)) ())))

(print (compile-to-blc `(lambda (x y z) (x y ((x y z) x)))))
(print (compile-to-blc `(lambda (x y) x)))


;; (defun occurs-freely-in (expr env var)
;;   (labels
;;     (cond ((atom expr) (find var env)))))

(defun-lazy t (x y) x)
(defun-lazy nil (x y) y)
(defun-lazy cons (x y f) (f x y))
(defun-lazy car (l) (l t))
(defun-lazy cdr (l) (l nil))
(defun-lazy isnil (l) ((lambda (a) (a (lambda (v n x) nil) t)) l))

(defun-lazy not (x) (x nil t))
(defun-lazy and (x y) (x y nil))
(defun-lazy or (x y) (x t y))
(defun-lazy xor (x y) (x (not y) y))

(defun-lazy succ (n f x) (f (n f x)))
(defun-lazy pred (n f x) (n ((lambda (g h) (h (g f)))) (lambda (u) x) (lambda (u) u)))
(defun-lazy + (m n f x) (m f (n f x)))
(defun-lazy * (m n f x) (m (n f) x))
(defun-lazy - (m n) (n pred m))
(defun-lazy iszero (n) (n (lambda (x) nil) t))
(defun-lazy 0 (f x) x)
(defun-lazy 1 (f x) (f x))
(defun-lazy 2 (f x) (f (f x)))
(def-lazy 4 ((lambda (x) (x x)) 2))
(def-lazy 8 (* 2 4))
(def-lazy 16 ((lambda (x) (x x x)) 2))
(def-lazy 32 (* 2 16))
(def-lazy 64 (* 2 32))
(def-lazy 128 (* 2 128))
(def-lazy 256 ((lambda (x) (x x)) 4))
(defun-lazy <= (m n) (iszero (- m n)))
(defun-lazy >= (m n) (<= n m))

(defun-lazy if (x) x)


(print (curry (macroexpand-lazy `(if t (not t) t))))
(print (compile-to-blc `(if t (not t) t)))
(print (compile-to-blc `(lambda (stdin) (cons t (cons nil (cons t nil))))))
