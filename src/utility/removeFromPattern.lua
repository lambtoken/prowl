local tablex = require "libs.batteries.tablex"

local removeFromPattern = function(a, b)

    local temp

    if #a == #b then
        temp = tablex.deep_copy(a)

        for i = 1, #a do
            for j = 1, #a[1] do
                temp[j][i] = (a[j][i] == 1 or b[j][i] == 1) and 1 or 0
            end
        end

    else
        local larger = #a > #b and a or b
        local smaller = #a < #b and a or b

        temp = tablex.deep_copy(larger)

        for i = 1, #smaller do
            for j = 1, #smaller[1] do
                local offsetX = math.ceil(#larger[1] / 2) - math.ceil(#smaller[1] / 2)
                local offsetY = math.ceil(#larger / 2) - math.ceil(#smaller / 2)

                local largerX = i + offsetX
                local largerY = j + offsetY

                if larger == a then
                    temp[largerY][largerX] = (larger[largerY][largerX] == 1 and smaller[j][i] == 0) and 1 or 0
                elseif larger == b then
                    temp[largerY][largerX] = (larger[largerY][largerX] == 0 and smaller[j][i] == 1) and 1 or 0
                end
            end
        end
    end
    return temp
end

return removeFromPattern