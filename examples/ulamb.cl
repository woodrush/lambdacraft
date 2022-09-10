(load "./lambdacraft.cl")

(def-lazy "A" (+ 1 64))

(defun-lazy main (stdin)
  (cons "A" nil))

(format t (compile-to-blc-lazy main))
