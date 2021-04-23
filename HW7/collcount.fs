\ collcount.fs
\ Robert Lawton
\ 16 April 2021
\ CS 331 - Assignment 7
\ Exercise 2 - Programming in Forth

\ collatz
\ given an integer n, return the collatz function value
\ c(n) = 3n + 1     if n is odd
\      = n/2        if n is even
: collatz ( n -- C[n] )
	dup 2 mod 0 = if	\ Duplicate stack item, then if even
		2 /				
	else				\ Else if stack item was odd
		3 * 1 + 		
	then				\ Stack: ... C[n]
;



\ collcount
\ Given a positive integer n, return c, the number of iterations of collatz
\ required to take n to 1
: collcount ( n -- c )
    0
    swap
    begin
        dup 1 = if
        else
            swap
            1 + 
            swap
            collatz
        then
        dup 1 = 
    until
    drop
;