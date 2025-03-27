local arrays = {}

arrays.scaleArray = function(array, targetSize)
    local sourceSize = #array
    local scaledArray = {}

    for i = 1, targetSize do
        scaledArray[i] = {}
        for j = 1, targetSize do
            local sourceX = (i - 1) * (sourceSize - 1) / (targetSize - 1) + 1
            local sourceY = (j - 1) * (sourceSize - 1) / (targetSize - 1) + 1

            local x1, y1 = math.floor(sourceX), math.floor(sourceY)
            local x2, y2 = math.min(x1 + 1, sourceSize), math.min(y1 + 1, sourceSize)

            local fracX, fracY = sourceX - x1, sourceY - y1

            local value = (1 - fracX) * (1 - fracY) * array[x1][y1]
                        + fracX * (1 - fracY) * array[x2][y1]
                        + (1 - fracX) * fracY * array[x1][y2]
                        + fracX * fracY * array[x2][y2]
            if value == 1 and i % 2 == 1 and j % 2 == 1 then
                scaledArray[i][j] = value
                          
            else 
                scaledArray[i][j] = 0
                          
            end

        end
    end

    return scaledArray
end

return arrays