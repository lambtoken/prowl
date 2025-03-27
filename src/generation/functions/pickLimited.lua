local tablex = require "libs.batteries.tablex"
local function isInTable(table, value)
    for index, v in ipairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

local function limitReached(value, n, table)

    if n ~= 0 then
        local count = 0
    
        for index, v in ipairs(table) do
            if value == v then
                count = count + 1
                if count >= n then
                    return true
                end
            end
        end
    end

    return false
end


local function pickLimited(rates, amount, pool)

    local rates_copy = tablex.deep_copy(rates)

    local totalRate = 0

    for _, item in ipairs(rates) do
        totalRate = totalRate + item.rate
    end
    
    while #pool < amount or #rates_copy == 0 do

        local pick = math.random(totalRate)
        
        for name, item in pairs(rates_copy) do
            pick = pick - item.rate
    
            if pick <= 0 then
                if not limitReached(item.name, item.limit, pool) then
                    table.insert(pool, item.name)  
                    goto continue
                else
                    rates_copy[name] = nil
                end
            end

        end

        ::continue::

    end

end

return pickLimited