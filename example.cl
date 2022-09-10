(load "./lambdacraft.cl")

(defrec-lazy fact (n)
  (if (<= n 0)
    1
    (* n (fact (- n 1)))))

(format t "~a~%~%" (compile-to-lisp-pretty-lazy fact))
(format t "~a~%~%" (compile-to-lisp-lazy fact))
(format t "~a~%~%" (compile-to-plaintext-lambda-lazy fact))
(format t "~a~%~%" (compile-to-blc-lazy fact))
(format t "~a~%~%" (compile-to-ski-lazy fact))
(format t "~a~%~%" (compile-to-ski-parens-lazy fact))
(format t "~a~%~%" (compile-to-js-lazy fact))
(format t "~a~%~%" (compile-to-js-arrow-lazy fact))
(format t "~a~%~%" (compile-to-python-lazy fact))
