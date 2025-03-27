local functions = {}

    functions.pickOne = function(rateTable)

        local bingoDrum = {}

        for i, _ in ipairs(rateTable) do
            for i = 1, _[2] do
                table.insert(bingoDrum, _[1])
            end
        end

        return bingoDrum[math.ceil(math.random() * #bingoDrum)]

    end

return functions