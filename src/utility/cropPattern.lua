local function crop(pattern, x1, y1, x2, y2)
    assert(x1 and x2 and y1 and y2, "Argument nil or false.")
    assert(type(x1) == "number" and type(x2) == "number" 
        and type(y1) == "number" and type(y2) == "number", "Number expected.")
    assert(x1 <= x2, "x1 cannot be greater than x2 when cropping the pattern")
    assert(y1 <= y2, "y1 cannot be greater than y2 when cropping the pattern")

    local new = {}

    for i = y1, y2, 1 do
        local newY = i - y1 + 1
        new[newY] = {}
        for j = x1, x2, 1 do
        local newX = j - x1 + 1
            local cell = pattern[i][j]
            new[newY][newX] = cell
        end
    end

    return new
end

return crop