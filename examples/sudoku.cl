(load "./lambdacraft.cl")
(load "./examples/wrapper.cl")

;; Solves a sudoku board using backtracking.
;;
;; Example input:
;; 4 167 329
;;  8 4 5  7
;;  7   9 8 
;; 1  34   8
;; 26 5   4 
;; 53  8 1  
;; 81526  9 
;;  4   15  
;; 32 7 4861
;;
;; Characters that are not digits and spaces `[^0-9 ]` are ignored.
;; Newlines for each row are optional.
;;
;; Example usage:
;; $ sbcl --script examples/sudoku.cl > sudoku.blc; ( cat sudoku.blc | bin/asc2bin; cat examples/sudoku_example.txt; ) | bin/uni++
;; Run this at the repo root.


(def-lazy 3 (succ 2))
(def-lazy 5 (succ 4))
(def-lazy 6 (+ 2 4))
(def-lazy 7 (+ 3 4))
(def-lazy 9 (succ 8))
(def-lazy 10 (+ 2 8))
(def-lazy 48 (+ 16 32))
(def-lazy "0" (+ 0 48))
(def-lazy "1" (+ 1 48))
(def-lazy "2" (+ 2 48))
(def-lazy "3" (+ 3 48))
(def-lazy "4" (+ 4 48))
(def-lazy "5" (+ 5 48))
(def-lazy "6" (+ 6 48))
(def-lazy "7" (+ 7 48))
(def-lazy "8" (+ 8 48))
(def-lazy "9" (+ 9 48))
(def-lazy " " 32)
(def-lazy "<" (- 64 4))
(def-lazy "\b" 8)
(def-lazy "\n" (+ 2 8))
(def-lazy 81 (+ 64 (+ 16 1)))


;; When used in a `do` sequence, this macro binds the car and cdr of the provided list,
;; to the variable names specified in `args`
(defmacro-lazy if-isnil (l args nilcase listcase)
  `(,l (lambda ,(append args `(_)) ,listcase) ,nilcase))

(defrec-lazy is-in-row-column (board i j ref n mode)
  (do
    (if (<= 9 i)
      (is-in-row-column board 0 (succ j) ref n mode))
    (if-isnil board (car-board cdr-board)
      nil)
    (if (and (= n car-board)
             (mode (= i ref)
                   (= j ref)))
      t)
    (is-in-row-column cdr-board (succ i) j ref n mode)))


(defun-lazy div-by3 (n)
  (cond
    ((<= n 2)
      0)
    ((<= n 5)
      1)
    (t
      2)))

(defrec-lazy is-in-block (board i j m n a)
  (do
    (if (<= 9 i)
      (is-in-block board 0 (succ j) m n a))
    (if-isnil board (car-board cdr-board)
      nil)
    (if (and
          (and
            (= m (div-by3 i))
            (= n (div-by3 j)))
          (= a car-board))
      t)
    (is-in-block cdr-board (succ i) j m n a)))


(defrec-lazy reverse-base (l tail cont)
  (do
    (if-isnil l (car-l cdr-l)
      (cont tail))
    (reverse-base cdr-l (cons car-l tail) cont)))

(defun-lazy reverse-c (l cont)
  (reverse-base l nil cont))

(defrec-lazy parse (stdin n buf return)
  (do
    (if (iszero n)
      (reverse-c buf return))
    (<- (car-stdin cdr-stdin) (stdin))
    (if (= " " car-stdin)
      (parse cdr-stdin (pred n) (cons 0 buf) return))
    ;; Digit
    (if (and (<= "1" car-stdin)
             (>= "9" car-stdin))
      (parse cdr-stdin (pred n) (cons (- car-stdin 48) buf) return))
    ;; Newline
    (parse cdr-stdin n buf return)))

(defrec-lazy print-board* (board i cont)
  (do
    (if (<= 9 i)
      (cons "\n" (print-board* board 0 cont)))
    (if-isnil board (car-board cdr-board)
      (cons "\n" cont))
    (cond
      ((iszero car-board)
        (cons " " (print-board* cdr-board (succ i) cont)))
      (t
        (cons (+ 48 car-board) (print-board* cdr-board (succ i) cont))))))

(defun-lazy print-board (board cont)
  (print-board* board 0 cont))

(defrec-lazy replace (l k n return)
  (do
    (<- (car-l cdr-l) (l))
    (if (iszero k)
      (return (cons n cdr-l)))
    (<- (a) (replace cdr-l (pred k) n))
    (return (cons car-l a))))

(defun-lazy replace-board (board i j n return)
  (replace board (+ i (* 9 j)) n return))

(defrec-lazy solve (board lboard i j return)
  (do
    (if (<= 9 i)
      (solve board lboard 0 (succ j) return))
    (if-isnil lboard (car-lboard cdr-lboard)
      (return board))
    (if (not (iszero car-lboard))
      (solve board cdr-lboard (succ i) j return))
    ((letrec-lazy solve-loop (board n)
      (do
        (if (<= 10 n)
          (return nil))
        (let* continue (solve-loop board (succ n)))
        ;; Row check (nil)
        (if (is-in-row-column board 0 0 j n nil)
          continue)
        ;; Column check (t)
        (if (is-in-row-column board 0 0 i n t)
          continue)
        (if (is-in-block board 0 0 (div-by3 i) (div-by3 j) n)
          continue)
        (<- (board-replaced) (replace-board board i j n))
        (cons (+ 48 n))
        (<- (s) (solve board-replaced cdr-lboard (succ i) j))
        (if (isnil s)
          (cons "\b" (cons " " (cons "\b" continue))))
        (return s)))
      board 1)))

(defrec-lazy check-rules (board lboard i j return)
  (do
    (if (<= 9 i)
      (check-rules board lboard 0 (succ j) return))
    (if-isnil lboard (n cdr-lboard)
      (return t))
    (let* continue (check-rules board cdr-lboard (succ i) j return))
    (if (iszero n)
      continue)
    (<- (replaced) (replace-board board i j 0))
    (if (do (or (is-in-row-column replaced 0 0 j n nil))
            (or (is-in-row-column replaced 0 0 i n t))
            (is-in-block replaced 0 0 (div-by3 i) (div-by3 j) n))
      (return nil))
    continue))

(defun-lazy main-lazyk (stdin)
  (do
    (<- (input) (parse stdin 81 nil))
    (let* div-by3 div-by3)
    (let* is-in-block is-in-block)
    (let* is-in-row-column is-in-row-column)
    ;; (let* is-in-column is-in-column)
    (let* replace-board replace-board)
    (<- (a) (check-rules input input 0 0))
    (if (not a)
      (cons "0" (inflist 256)))
    (<- (result) (solve input input 0 0))
    (cons "\n")
    (if (isnil result)
      (cons "0" (inflist 256)))
    (print-board result (inflist 256))))

(defun-lazy main (stdin)
  (lazykstr-to-blcstr (main-lazyk (blcstr-to-lazykstr stdin))))

(format t (compile-to-blc-lazy main))

;; (format t (compile-to-ski-lazy main-lazyk))

;; (format t (compile-to-plaintext-lambda-lazy main-lazyk))