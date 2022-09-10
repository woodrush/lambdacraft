(load "./lambdacraft.cl")

(def-lazy "A" (+ 1 64))

(defun-lazy main (stdin)
  (cons "A" (inflist 256)))

(format t (compile-to-ski-lazy main))
