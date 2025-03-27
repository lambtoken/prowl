local Concord = require("libs.concord")
local itemData = require "src.generation.items"
local tablex = require "libs.batteries.tablex"
local pretty = require "libs.batteries.pretty"
local mergePatterns = require "src.utility.mergePatterns"
local extendPattern = require "src.utility.extendPattern"
local arrayManipulation = require "src.utility.arrayManipulation"
local removeFromPattern = require "src.utility.removeFromPattern"
local itemSystem = Concord.system({pool = {inventory, stats}})


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

function itemSystem:applyItemStats(entity)
    local items = entity.inventory.items
    local baseStats = entity.stats.base
    entity.stats.current = tablex.deep_copy(baseStats)
    entity.stats.currentPatterns = tablex.deep_copy(entity.stats.basePatterns)
    local stats = entity.stats.current

    -- base
    -- items, effects


    local case =
    {
        ["increase"] = function (toIncrease, amount) 
            stats[toIncrease] = stats[toIncrease] + amount
        end,
        
        ["decrease"] = function (toDecrease, amount)
            stats[toDecrease] = stats[toDecrease] - amount
        end,

        ["increaseP"] = function (toIncreaseP, amount) 
            stats[toIncreaseP] = stats[toIncreaseP] + math.floor((stats[toIncreaseP] / 100) * amount)
        end,
        
        ["decreaseP"] = function (toDecreaseP, amount)
            stats[toDecreaseP] = stats[toDecreaseP] - math.floor((stats[toDecreaseP] / 100) * amount)
        end,

        ["add"] = function(toAddTo, pattern) 
            entity.stats.currentPatterns[toAddTo] = mergePatterns(entity.stats.currentPatterns[toAddTo], pattern)
        end,

        ["extend"] = function(toExtend, pattern) 
            entity.stats.currentPatterns[toExtend] = extendPattern(entity.stats.currentPatterns[toExtend], pattern)
        end,

        ["remove"] = function(toRemoveTo, pattern) 
            entity.stats.currentPatterns[toRemoveTo] = removeFromPattern(entity.stats.currentPatterns[toRemoveTo], pattern)
        end,

        ["append"] = function (appendFrom, appendTo, percentage)
            entity.stats[appendTo] = entity.stats[appendTo] + math.floor(entity.stats[appendFrom] / 100 * percentage)
        end,

        ["swap"] = function (statA, statB)
            if (statA == 'atkPattern' or statA == 'movePattern') and (statB == 'atkPattern' or statB == 'movePattern') then
                local temp = tablex.deep_copy(entity.stats.currentPatterns[statA])
                entity.stats.currentPatterns[statA] = tablex.deep_copy(entity.stats.currentPatterns[statB])
                entity.stats.currentPatterns[statB] = temp
            else
                local temp = entity.stats.current[statA]
                entity.stats.current[statA] = entity.stats.current[statB]
                entity.stats.current[statB] = temp
            end
        
        end,

        default = function ( )
            print(" your choice didn't match any of those specified cases")
        end,
    }

    for i, _ in pairs(items) do
        if _.stats then
            for i, effect in ipairs(_.stats) do
                if (effect[1] == 'increase') then
                    case[effect[1]](effect[2], effect[3])
                end
            end
        end
    end

    for i, _ in ipairs(items) do
        if _.stats then
            for i, effect in ipairs(_.stats) do
                if (effect[1] == 'decrease') then
                    case[effect[1]](effect[2], effect[3])
                end
            end
        end
    end

    local increasePTable = {}

    for i, _ in ipairs(items) do
        if _.stats then
            for i, effect in ipairs(_.stats) do
                if (effect[1] == 'increaseP') then
                    if not increasePTable[effect[2]] then
                        increasePTable[effect[2]] = tablex.deep_copy(effect)
                    else
                        increasePTable[effect[2]][3] = increasePTable[effect[2]][3] + effect[3]    
                    end
                end
            end
        end
    end

    for i, _ in ipairs(increasePTable) do
        case[_[1]](_[2], _[3])
    end

    local decreasePTable = {}

    for i, _ in ipairs(items) do
        if _.stats then
            for i, effect in ipairs(_.stats) do
                if (effect[1] == 'decreaseP') then
                    if not decreasePTable[effect[2]] then
                        decreasePTable[effect[2]] = tablex.deep_copy(effect)
                    else
                        decreasePTable[effect[2]][3] = decreasePTable[effect[2]][3] + effect[3]
                    end
                end
            end
        end
    end

    for i, _ in ipairs(decreasePTable) do
        case[_[1]](_[2], _[3])
    end

    for i, _ in ipairs(items) do
        if _.pattern then
            for i, effect in ipairs(_.pattern) do
                if (effect[1] == 'add') then
                    case[effect[1]](effect[2], effect[3])
                end
            end
        end
    end

    for i, _ in ipairs(items) do
        if _.pattern then
            for i, effect in ipairs(_.pattern) do
                if (effect[1] == 'extend') then
                    case[effect[1]](effect[2], effect[3])
                end
            end
        end
    end

    for i, _ in ipairs(items) do
        if _.pattern then
            for i, effect in ipairs(_.pattern) do
                if (effect[1] == 'remove') then
                    case[effect[1]](effect[2], effect[3])
                end
            end
        end
    end

    for i, _ in ipairs(items) do
        if _.stats then
            for i, effect in ipairs(_.stats) do
                if (effect[1] == 'append') then
                    case[effect[1]](effect[2], effect[3], effect[4])
                end
            end
        end
    end

    for i, _ in ipairs(items) do
        if _.stats then
            for i, effect in ipairs(_.stats) do
                if (effect[1] == 'swap') then
                    case[effect[1]](effect[2], effect[3])
                end
            end
        end
    end

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
    self:applyItemStats(entity)
end

function itemSystem:unequipItem(entity, item)
    for i, equippedItem in ipairs(entity.inventory) do
        if equippedItem == item then
            table.remove(entity.items, i)
            self:applyItemStats(entity)
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


return itemSystem


-- item:
--      name
--      state
--      icon