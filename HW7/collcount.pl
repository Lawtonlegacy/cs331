% collcount.pl
% Robert Lawton
% 16 April 2021
% CS 331 - Assignment 7
% Exercise 4 - Programming in Prolog


% collcount/2
% collcount(+n, ?c)
collcount(1, 0).

% N is odd
collcount(N, C) :-    
    N > 1,
    N mod 2 =\= 0,
    N1 is 3 * N + 1,
    collcount(N1, C1),
    C is C1 + 1.

% N is even
collcount(N, C) :-
    N > 1,
    N mod 2 =:= 0,
    N1 is N / 2,
    collcount(N1, C1),
    C is C1 + 1.
