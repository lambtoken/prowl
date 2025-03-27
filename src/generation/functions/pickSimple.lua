local function pickSimple(rates)

    local totalRate = 0

    for _, item in ipairs(rates) do
        totalRate = totalRate + item.rate
    end

    local pick = math.random(totalRate)

    for name, item in pairs(rates) do
        pick = pick - item.rate

        if pick <= 0 then
            return item.name
        end
    end
    
end

return pickSimple