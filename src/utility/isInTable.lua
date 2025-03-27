return function(table, v)
    for index, value in ipairs(table) do
        if value == v then
            return true
        end
    end

    return false
end