local tablex = require "libs.batteries.tablex"

local function removeFromPattern(a, b)
    local temp

    if #a == #b and #a[1] == #b[1] then
        temp = tablex.deep_copy(a)

        for i = 1, #a do
            for j = 1, #a[1] do
                temp[i][j] = (a[i][j] == 1 and b[i][j] == 0) and 1 or 0
            end
        end

    else
        local larger, smaller = (#a > #b) and a or b, (#a < #b) and a or b
        local tempLarger = tablex.deep_copy(larger)
        local offsetY = math.ceil(#larger / 2) - math.ceil(#smaller / 2)
        local offsetX = math.ceil(#larger[1] / 2) - math.ceil(#smaller[1] / 2)

        for i = 1, #smaller do
            for j = 1, #smaller[1] do
                local y = i + offsetY
                local x = j + offsetX

                if y >= 1 and y <= #larger and x >= 1 and x <= #larger[1] then
                    if larger == a then
                        tempLarger[y][x] = (larger[y][x] == 1 and smaller[i][j] == 0) and 1 or 0
                    else
                        tempLarger[y][x] = (larger[y][x] == 0 and smaller[i][j] == 1) and 1 or 0
                    end
                end
            end
        end

        temp = tempLarger
    end

    return temp
end

return removeFromPattern