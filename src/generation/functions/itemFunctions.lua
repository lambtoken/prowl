local items = require 'src.generation.items'

local itemFunctions = {}

itemFunctions.getRandomItem = function(list)
    
    if list then
        return list[math.ceil(math.random() * #items)]
    else 
        local keys = {}
        for key, _ in pairs(items) do
            table.insert(keys, key)
        end
    
        local randomKey = keys[math.ceil(math.random(#keys))]
        
        return items[randomKey]
    end
end

itemFunctions.getItem = function(item)
    return items[item]
end

itemFunctions.getAllByRarity = function(rarity)
    local list = {}

    for i, _ in pairs(items) do
        if _.rarity == rarity then
            table.insert(list, _)
        end
    end

end

return itemFunctions