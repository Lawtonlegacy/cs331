-- PA5.hs
-- Robert Lawton
-- 23 March 2021
-- Skeleton Code is from Glenn G. Chappell
-- For CS F331 / CSCE A331 Spring 2021
-- Solutions to Assignment 5 Exercise B

module PA5 where


-- collatzCounts
-- This is a list of Integer values. Item n (counting from zero) of collatzCounts tell 
-- how many iterations of the Collatz function are required to take the number n+1 to n.
collatzCounts :: [Integer]
collatzCounts = map counter [1..] where
  counter n
    | n == 1    = 0
    | even n    = 1 + counter (div n 2)
    | otherwise = 1 + counter (3 * n + 1)


-- findList
-- Takes two lists of the same type and returns a Maybe Int.
-- It the first list is found as a continguous sublist of the second list, then the return value is Just n, 
-- where n is the earlier index (starting from zero) at which a copy of the first list begins.
-- If the first list is not found as a contiguous sublist of the second, then the return value is Nothing. 
findList :: Eq a => [a] -> [a] -> Maybe Int
findList [] _ = Just 0
findList xs ys = let n = 0 in match xs ys n where
  match xs ys n
    | take (length xs) ys == xs     = Just n
    | length xs > length ys         = Nothing
    | otherwise                     = match xs (tail ys) (n + 1)


-- Infix operator ##
-- The two operands are lists of the same type. The return value is an Int 
-- giving the number of indices at which the two lists contain equal values.
(##) :: Eq a => [a] -> [a] -> Int
_ ## [] = 0
[] ## _ = 0
list1 ## list2 = length $ filter (True==) $ zipWith (==) list1 list2


-- filterAB
-- This takes a boolean function and two lists. It returns a list of all items in the second list
-- for which the corresponding item in the first list makes the boolean function true.
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ [] = []
filterAB _ [] _ = []
filterAB temp list1 list2 = 
  map snd $ filter ((==True) . fst) $ zip (map temp list1) list2


-- sumEvenOdd
-- 
sumEvenOdd :: Num a => [a] -> (a, a)
sumEvenOdd xs = (foldr (+) 0 evenNumbers, foldr (+) 0 oddNumbers) where
  evenNumbers = map fst $ filter (even . snd) $ zip xs [0..]
  oddNumbers = map fst $ filter (odd . snd) $ zip xs [0..]
