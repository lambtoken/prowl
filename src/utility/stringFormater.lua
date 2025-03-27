local function format(string, font, width)

    local rows = {''}
    local nRow = 1
    local length = 0

    for word in string:gmatch("%S+") do
        
        length = length + font:getWidth(word .. " ")
        
        if length > width then
            nRow = nRow + 1
            rows[nRow] = ''
            length = 0
        end

        rows[nRow] = rows[nRow] .. ' ' .. word
    end

    return rows
end

return format