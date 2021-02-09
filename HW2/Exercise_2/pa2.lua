-- pa2.lua
-- Robert Lawton
-- 03 February 2021
-- pa2 module for CS 331: HW2 Exercise 2 

local pa2 = {}

-- function filterArray

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

function pa2.concatMax(str, int)
    return string.rep(str,math.floor(int/str:len()))
end

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

function pa2.substrings(s)
    -- base case empty string
    coroutine.yield("")
    local len = s:len()
    local sublen = 1
    local from = 1
    local to = 0
    local numsubs = len*(len+1)/2

    for i=1, numsubs do
        to = to+1
        if to > len then
            from = from+1
            to = from
        end
        local substring = s:sub(from,to)
        if #substring ~= 0 then
            coroutine.yield(substring)
        end
        i = i+1
    end
end




return pa2