local itemData = require "src.generation.items"

local function getItemsByRarity(rarity)
    local items = {}

    for key, value in pairs(itemData) do
        if value.rarity == rarity then
            table.insert(items, key)
        end
    end

    return items
end

return getItemsByRarity