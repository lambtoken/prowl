local Concord = require("libs.concord")
local EventManager = require("src.state.events"):getInstance()
local joinTables = require "src.utility.joinTables"
local tablex = require "libs.batteries.tablex"
local mergePatterns = require "src.utility.mergePatterns"
local extendPattern = require "src.utility.extendPattern"
local arrayManipulation = require "src.utility.arrayManipulation"
local removeFromPattern = require "src.utility.removeFromPattern"

local statsSystem = Concord.system({pool = {inventory, stats}})

function statsSystem:init()
    EventManager:on("calculateStats", function()
        self:calculateStats()
    end)
end

function statsSystem:updateState()
    for index, value in ipairs(self.pool) do
        
    end
end

function statsSystem:calculateStats()
    print(123)
    for _, entity in ipairs(self.pool) do
        print(123321)

        local items = entity.inventory.items
        local baseStats = entity.stats.base
        local statEffects = {}
        local patternEffects = {}

        for _, item in ipairs(items) do
            if item.stats then
                for _, s in ipairs(item.stats) do
                    table.insert(statEffects, s)
                end
            end

            if item.pattern then
                for _, p in ipairs(item.pattern) do
                    table.insert(patternEffects, p)
                end
            end
        end

        if entity.buffsDebuffs and entity.buffsDebuffs.effects then        
            for _, effect in ipairs(entity.buffsDebuffs.effects) do
                if effect.stats then
                    for _, s in ipairs(effect.stats) do
                        table.insert(statEffects, s)
                    end
                end

                if effect.pattern then
                    for _, p in ipairs(effect.pattern) do
                        table.insert(patternEffects, p)
                    end
                end
            end
        end

        -- if entity.buffsDebuffs and entity.buffsDebuffs.effects then
        --     t = joinTables(t, entity.buffsDebuffs.effects)
        -- end

        -- if entity.status and entity.status.effects then
        --     t = joinTables(t, entity.status.effects)
        -- end

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
    
        for i, effect in pairs(statEffects) do
            if (effect[1] == 'increase') then
                case[effect[1]](effect[2], effect[3])
            end
        end
    
        for i, effect in ipairs(statEffects) do
            if (effect[1] == 'decrease') then
                case[effect[1]](effect[2], effect[3])
            end
        end
    
        local increasePTable = {}
    
        for i, effect in ipairs(statEffects) do
            if (effect[1] == 'increaseP') then
                if not increasePTable[effect[2]] then
                    increasePTable[effect[2]] = tablex.deep_copy(effect)
                else
                    increasePTable[effect[2]][3] = increasePTable[effect[2]][3] + effect[3]    
                end
            end
        end
    
        for i, _ in ipairs(increasePTable) do
            case[_[1]](_[2], _[3])
        end
    
        local decreasePTable = {}
    
        for i, effect in ipairs(statEffects) do
            if (effect[1] == 'decreaseP') then
                if not decreasePTable[effect[2]] then
                    decreasePTable[effect[2]] = tablex.deep_copy(effect)
                else
                    decreasePTable[effect[2]][3] = decreasePTable[effect[2]][3] + effect[3]
                end
            end
        end
    
        for i, _ in ipairs(decreasePTable) do
            case[_[1]](_[2], _[3])
        end
    
        for i, effect in ipairs(patternEffects) do
            if (effect[1] == 'add') then
                case[effect[1]](effect[2], effect[3])
            end
        end
    
        for i, effect in ipairs(patternEffects) do
            if (effect[1] == 'extend') then
                case[effect[1]](effect[2], effect[3])
            end
        end
    
        for i, effect in ipairs(patternEffects) do
            if (effect[1] == 'remove') then
                case[effect[1]](effect[2], effect[3])
            end
        end
    
        for i, effect in ipairs(patternEffects) do
            if (effect[1] == 'append') then
                case[effect[1]](effect[2], effect[3], effect[4])
            end
        end
    
        for i, effect in ipairs(patternEffects) do
            if (effect[1] == 'swap') then
                case[effect[1]](effect[2], effect[3])
            end
        end

    end
end


return statsSystem