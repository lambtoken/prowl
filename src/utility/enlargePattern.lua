local function enlarge(pattern, amount)
    local width = #pattern[1]
    local height = #pattern

    amount = amount or 1

    local newWidth = width + amount * 2
    local newHeight = height + amount * 2

    local newPattern = {}

    for i = 1, newHeight do
    
        newPattern[i] = {}
    
        for j = 1, newWidth do
        
            if i > amount and i <= height + amount 
            and j > amount and j <= width + amount then
                newPattern[i][j] = pattern[i - amount][j - amount]
            else
                newPattern[i][j] = 0
            end 

        end
    end

    return newPattern
end

return enlarge