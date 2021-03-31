-- median.hs
-- Robert Lawton
-- 23 March 2021
-- For CS F331 / CSCE A331 Spring 2021
-- Glenn G. Chappell
-- Solutions to Assignment 5 Exercise C

module Main where
import Data.List    -- for sort
import System.IO    -- for hFlush, stdout

-- getUserInput
-- Returns list of user inputs and ends if given blank line
getUserInput :: IO [Int]
getUserInput = do
    putStr "Enter number (blank line to end): "
    hFlush stdout
    input <- getLine
    if input == "" then
        return []
    else do
        let current = read input
        next <- getUserInput
        return (current:next)

-- median
-- Returns the median of a given list
median :: [a] -> a
median list = list !! (length list `div` 2)

main :: IO [a]
main = do
    putStrLn "Enter a list of integers, one on each line."
    putStrLn "I will compute the median of the list."
    putStrLn ""
    hFlush stdout
    input <- getUserInput

    if null input then do
        putStrLn "Empty list - no median"
        restart
    else do
        putStrLn ("Median: " ++ show (median (sort input)))
        restart

restart :: IO [a]
restart = do
    putStrLn ""
    putStr "Compute another median? [y/n] "
    hFlush  stdout
    choice <- getLine
    if choice == "Y" || choice == "y" then do
        putStrLn ""
        main
    else if choice == "N"|| choice == "n" then do
        putStrLn "Bye!"
        return []
    else
        restart
        