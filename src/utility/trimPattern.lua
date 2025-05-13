local crop = require "src.utility.cropPattern"

-- input
-- {
--     {0, 0, 0, 0, 0},
--     {0, 1, 0, 0, 0},
--     {0, 0, 1, 0, 0},
--     {0, 0, 0, 1, 0},
--     {0, 0, 0, 0, 0},
-- }

-- output
-- {
--     {1, 0, 0},
--     {0, 1, 0},
--     {0, 0, 1},
-- }

local trim = function(pattern)

    -- scan
    local len = #pattern
    local new = {}

    local level = len
    local min, max

    while level > 2 do
        for i = 1, level, 1 do
            for j = 1, level, 1 do
                min = (len - level) / 2 + 1
                max = len - (len - level) / 2
                if i == min or j == max or i == max or j == min then
                    local x = (len - level) / 2 + j
                    local y = (len - level) / 2 + i
                    local cell = pattern[y][x]
                    if cell == 1 then
                        goto escape
                    end
                end
            end
        end
        level = level - 2
    end

    ::escape::

    return crop(pattern, min, min, max, max)

end

return trim
