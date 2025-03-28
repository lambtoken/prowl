local function joinTables(table1, table2)
    local result = {}
    local index = 1

    -- Copy elements from table1
    for i = 1, #table1 do
        result[index] = table1[i]
        index = index + 1
    end

    -- Copy elements from table2
    for i = 1, #table2 do
        result[index] = table2[i]
        index = index + 1
    end

    return result
end

return joinTables