(load "./lambdacraft.cl")

(def-lazy "A" (list t nil t t t t t nil))

(defun-lazy main (stdin)
  (cons "A" nil))

(format t (compile-to-blc-lazy main))
