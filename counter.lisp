(defvar new-counter
    (lambda (c)
        (let ((a ()) (c c))
            (lambda () (setq a (cons c a))))))
(defvar counter1 (new-counter (quote a)))
(defvar counter2 (new-counter (quote b)))
(counter1)
(counter1)
(counter1)
(counter2)
(counter2)
(counter1)
(counter1)
