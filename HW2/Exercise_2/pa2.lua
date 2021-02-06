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


return pa2