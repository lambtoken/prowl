local Concord = require("libs.concord")
local itemData = require "src.generation.items"
local EventManager = require ("src.state.events"):getInstance()
local tablex = require "libs.batteries.tablex"
local pretty = require "libs.batteries.pretty"
local gs = require("src.state.GameState"):getInstance()

local itemSystem = Concord.system({pool = {inventory, stats}})

function itemSystem:init()
end

function itemSystem:update(dt)
    for _, entity in ipairs(self.pool) do 
    end
end

function itemSystem:newItem(name)
    assert(itemData[name], "Item " .. name .. " doesn't exist!")

    local item = {}
    item.name = name
    if itemData[name].stats then item.stats = tablex.deep_copy(itemData[name].stats) end
    if itemData[name].pattern then item.pattern = tablex.deep_copy(itemData[name].pattern) end
    if itemData[name].passive then item.passive = tablex.deep_copy(itemData[name].passive) end
    return item
end


-- function itemSystem:disableItemStats(entity, item)
--     local items = entity.items

--     for i, equippedItem in ipairs(entity.items) do
--         if equippedItem == item then
--             item.disabled = true
--             break
--         end
--     end    
-- end

-- function itemSystem:enableItemStats(entity, item)
--     local items = entity.items

--     for i, equippedItem in ipairs(entity.items) do
--         if equippedItem == item then
--             item.disabled = false
--             break
--         end
--     end    
-- end

function itemSystem:giveItem(entity, itemName)
    table.insert(entity.inventory.items, self:newItem(itemName))
    --gs.currentMatch.ecs:getSystem(gs.currentMatch.__systems.statsSystem):calculateStats()

    --EventManager:emit("calculateStats")
end

function itemSystem:unequipItem(entity, item)
    for i, equippedItem in ipairs(entity.inventory) do
        if equippedItem == 0 then
            table.remove(entity.items, i)
            EventManager:emit("calculateStats")
            break
        end
    end
end

function itemSystem:hasItem(entity, itemName)
    for _, item in ipairs(entity.inventory) do
        if item.name == itemName then
            return true
        end
    end
    return false
end

function itemSystem:onStandBy()
    for index, animal in ipairs(self.pool) do
        for index, item in ipairs(animal.inventory.items) do
            if item.passive.cooldown then
                item.passive.cooldown = item.passive.cooldown - 1
                
            end
        end    
    end
end


return itemSystem