#lang scheme
; addpairs.scm
; Robert Lawton
; 16 April 2021
; CS 331 - Assignment 7
; Exercise 3 - Programming in scheme


; Procedure addpairs
; Takes an arbitrary number of arguments, which should be numbers.
; Returns a list consisting of the sum of the first two numbers, then
; the sume of the next two numbers, etc. If there are an odd number of
; arguments, then the last time in the returned list is the last argument.
(define (addpairs . arguments)

    ; Nested Procedure
    (define (add arguments)
        (cond
            ; Returns arguments if length is <= 1
            [(<= (length arguments) 1) arguments]

            ; else return appeneded list
            [(append (list (+ (car arguments) (car (cdr arguments))))(add (cdr (cdr arguments))))]
        )
    )
    ; return value
    (add arguments)
)