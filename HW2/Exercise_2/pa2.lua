-- pa2.lua
-- Robert Lawton
-- 03 February 2021
-- pa2 module for CS 331: HW2 Exercise 2 

-- create module
local pa2 = {}

-- function filterArray
-- Returns an array containing every value v in t for
-- which p(v) is truthy, in the same order as they appear in t.
-- Preconditions:
--      "p" must be a single-parameter function that accepts any value in array "t"
--      "t" must be a an array like table
function pa2.filterArray(p,t)
    local arr = {}
    local i = 1
    for k,v in ipairs(t) do 
        if p(v) == true then
            arr[i] = v
            i = i+1
        end
    end
    return arr
end

-- function concatMax
-- Takes a string and an integer. Returns a string which is a which is the concatenation of as
-- many copies of the given string as possible, without the length exceeding the given integer.
-- Preconditions:
--      "str" is a valid string object.
--      "int" is a valid number object with no decimal.
function pa2.concatMax(str, int)
    return string.rep(str,math.floor(int/str:len()))
end

-- function collatz
-- collatz takes an integer parameter k and returns an iterator that produces one or more integers.
-- Preconditions:
--      "k" is a valid positive number object with no decimal.
function pa2.collatz(k)
    local function iterator()
        if k == 1 then
            k = 0
            return 1
        elseif k>1 then
            local var = k
            if k%2==1 then
                k = 3*k+1
            else
                k=k/2
            end
            return var
        end
    end
    return iterator
end

-- function substrings
-- Takes a single parameter s, which must be a string. It yields all substrings of s: 
-- first the unique length-zero substring, then all length-one substrings, and so on, ending with s itself.
-- Uses coroutine module with function.
-- Preconditions:
--      "s" is a vaild string object
function pa2.substrings(s)
    -- base case empty string
    coroutine.yield("")
    local len = s:len()
    local sublen = 0
    local from = 0
    local to = 0
    local numsubs = (len*(len+1)/2)+len

    for i=1, numsubs do
        from = from+1
        to = from + sublen
        -- increment sublen
        if to > len then
            sublen = sublen + 1
            from = 0
            to = 0
        end
        local substring = s:sub(from,to)
        if #substring ~= 0 then
            coroutine.yield(substring)
        end
        i = i+1
    end
end

-- export module
return pa2