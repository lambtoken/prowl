local Concord = require("libs.concord")
local itemData = require "src.generation.items"
local EventManager = require ("src.state.events"):getInstance()
local tablex = require "libs.batteries.tablex"
local pretty = require "libs.batteries.pretty"
local gs = require("src.state.GameState"):getInstance()
local uuid = require "src.utility.uuid"

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
    item.id = uuid()
    
    if itemData[name].stats then item.stats = tablex.deep_copy(itemData[name].stats) end
    if itemData[name].pattern then item.pattern = tablex.deep_copy(itemData[name].pattern) end
    if itemData[name].passive then item.passive = tablex.deep_copy(itemData[name].passive) end
    if itemData[name].active then item.active = tablex.deep_copy(itemData[name].active) end
    if itemData[name].cooldowns then item.cooldowns = tablex.deep_copy(itemData[name].cooldowns) end
    if itemData[name].data then item.data = tablex.deep_copy(itemData[name].data) end
    
    if itemData[name].startCooldowns then
        for key, value in pairs(itemData[name].startCooldowns) do
            item.cooldowns[key] = value
        end
    end

    return item
end

function itemSystem:giveItem(entity, itemName)
    local newItem = self:newItem(itemName)
    table.insert(entity.inventory.items, newItem)
    return newItem -- Return the created item with its ID
end

function itemSystem:unequipItem(entity, item)
    for i, equippedItem in ipairs(entity.inventory.items) do
        if equippedItem == item then
            table.remove(entity.inventory.items, i)
            EventManager:emit("calculateStats")
            break
        end
    end
end

function itemSystem:unequipItemById(entity, itemId)
    for i, equippedItem in ipairs(entity.inventory.items) do
        if equippedItem.id == itemId then
            table.remove(entity.inventory.items, i)
            EventManager:emit("calculateStats")
            break
        end
    end
end

function itemSystem:hasItem(entity, itemName)
    for _, item in ipairs(entity.inventory.items) do
        if item.name == itemName then
            return true
        end
    end
    return false
end

function itemSystem:findItemById(entity, itemId)
    for _, item in ipairs(entity.inventory.items) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

function itemSystem:reduceCooldown(item, event)
    if item.cooldowns and item.cooldowns[event] then
        if item.cooldowns[event] > 0 then
            item.cooldowns[event] = item.cooldowns[event] - 1
        end
    end
end

function itemSystem:restoreCooldown(item, event)
    -- print("restoreCooldown", item.name, event)
    if item.cooldowns and item.cooldowns[event] then
        item.cooldowns[event] = itemData[item.name].cooldowns[event]
    end
end

function itemSystem:onStandBy(teamId)
    for _, animal in ipairs(self.pool) do
        if not animal.inventory or animal.metadata.teamId ~= teamId then
            goto skip_animal
        end

        for _, item in ipairs(animal.inventory.items) do
            if item.cooldowns then
                for event, value in pairs(item.cooldowns) do
                    self:reduceCooldown(item, event)
                end
            end
            if item.passive and item.passive.onStandBy then
                if item.cooldowns and item.cooldowns["onStandBy"] > 0 then
                    goto skip_item
                end
                item.passive.onStandBy(gs.match, animal, item)
                self:restoreCooldown(item, "onStandBy")
            end
            ::skip_item::
        end    
        ::skip_animal::
    end
end


return itemSystem