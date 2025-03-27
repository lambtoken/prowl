local getItemsByRarity = require "src.generation.functions.getItemsByRarity"
local stageItemRarityRates = require "src.generation.stageItemRarityRates"
local pickSimple = require "src.generation.functions.pickSimple"

local function isInTable(value, table)
    for _, v in ipairs(table) do
        if value == v then
            return true
        end
    end
    return false
end

local getRandomItems = function(stage, n)
    local items = {}

    while #items < n do
        local rarity = pickSimple(stageItemRarityRates[stage])

        local rarity_items = getItemsByRarity(rarity)
        
        if #rarity_items == 0 then
            goto continue
        end

        local item = rarity_items[math.random(#rarity_items)]

        if not isInTable(item, items) then
            table.insert(items, item)
        end

        ::continue::
    end

    return items
end

return getRandomItems