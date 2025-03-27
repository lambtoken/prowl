local tablex = require "libs.batteries.tablex"
local enlargePattern = require "src.utility.enlargePattern"

local extendPattern = function(a, b)
    local temp = tablex.deep_copy(a)
    local largerCenterX = math.ceil(#temp[1] / 2)
    local largerCenterY = math.ceil(#temp / 2)

    for i = -1, 1 do
        for j = -1, 1 do
            if not (i == 0 and j == 0) and b[i + 2][j + 2] == 1 then

                local increment = 1

                while true do
                    local largerX = largerCenterX + increment * j
                    local largerY = largerCenterY + increment * i

                    if largerX < 1 or largerY < 1 or largerY > #temp or largerX > #temp[1] then
                        break
                    end

                    if temp[largerY][largerX] == 1 then
                        
                        if not temp[largerY + i] or not temp[largerY + i][largerX + j] then

                            temp = enlargePattern(temp)
                            
                            largerCenterX = math.ceil(#temp[1] / 2)
                            largerCenterY = math.ceil(#temp / 2)
                            largerX = largerCenterX + increment * j
                            largerY = largerCenterY + increment * i 
                        end
                        
                        if temp[largerY + i][largerX + j] == 0 then
                            temp[largerY + i][largerX + j] = 1
                            break
                        end

                    end

                    increment = increment + 1
                end
            end
        end
    end

    return temp
end

return extendPattern
