local Concord = require("libs.concord")
local EventManager = require("src.state.events"):getInstance()
local joinTables = require "src.utility.joinTables"
local tablex = require "libs.batteries.tablex"
local mergePatterns = require "src.utility.mergePatterns"
local extendPattern = require "src.utility.extendPattern"
local arrayManipulation = require "src.utility.arrayManipulation"
local removeFromPattern = require "src.utility.removeFromPattern"

local statsSystem = Concord.system({ pool = { inventory, stats } })

function statsSystem:init()
    EventManager:on("calculateStats", function()
        self:calculateStats()
    end)
end

function statsSystem:initializeStats()
    self:calculateStats(false)
end

function statsSystem:calculateStats(preserveHp)
    preserveHp = preserveHp ~= false

    for _, entity in ipairs(self.pool) do
        if not entity.inventory or not entity.stats then goto continue end

        local oldHp = preserveHp and entity.stats.current.hp
        local items = entity.inventory.items
        local baseStats = entity.stats.base
        local basePatterns = entity.stats.basePatterns
        local statEffects, patternEffects = {}, {}

        if preserveHp then baseStats.hp = oldHp end

        local sources = {
            items,
            (entity.buffDebuff and entity.buffDebuff.effects) or {}
        }

        for _, source in ipairs(sources) do
            for _, item in ipairs(source) do
                if item.stats then
                    table.move(item.stats, 1, #item.stats, #statEffects + 1, statEffects)
                end
                if item.pattern then
                    table.move(item.pattern, 1, #item.pattern, #patternEffects + 1, patternEffects)
                end
            end
        end

        local currentStats = tablex.deep_copy(baseStats)
        local currentPatterns = tablex.deep_copy(basePatterns)
        entity.stats.current = currentStats
        entity.stats.currentPatterns = currentPatterns

        local increasePTable, decreasePTable = {}, {}

        local function mergePctTable(tbl, tag, k, v)
            if not tbl[k] then
                tbl[k] = { tag, k, v }
            else
                tbl[k][3] = tbl[k][3] + v
            end
        end

        local statHandlers = {
            increase = function(k, v) currentStats[k] = currentStats[k] + v end,
            decrease = function(k, v) currentStats[k] = currentStats[k] - v end,
            increaseP = function(k, v) currentStats[k] = currentStats[k] + math.floor(currentStats[k] * v / 100) end,
            decreaseP = function(k, v) currentStats[k] = currentStats[k] - math.floor(currentStats[k] * v / 100) end,
            append = function(from, to, pct)
                currentStats[to] = currentStats[to] + math.floor(currentStats[from] * pct / 100)
            end,
            swap = function(a, b)
                if (a == 'atkPattern' or a == 'movePattern') and (b == 'atkPattern' or b == 'movePattern') then
                    local temp = tablex.deep_copy(currentPatterns[a])
                    currentPatterns[a] = tablex.deep_copy(currentPatterns[b])
                    currentPatterns[b] = temp
                else
                    local temp = currentStats[a]
                    currentStats[a] = currentStats[b]
                    currentStats[b] = temp
                end
            end
        }

        local patternHandlers = {
            add = function(k, v)
                currentPatterns[k] = mergePatterns(currentPatterns[k], v)
            end,
            extend = function(k, v)
                currentPatterns[k] = extendPattern(currentPatterns[k], v)
            end,
            remove = function(k, v)
                currentPatterns[k] = removeFromPattern(currentPatterns[k], v)
            end
        }

        for _, effect in ipairs(statEffects) do
            local tag, k, v = effect[1], effect[2], effect[3]
            if tag == "increaseP" then
                mergePctTable(increasePTable, tag, k, v)
            elseif tag == "decreaseP" then
                mergePctTable(decreasePTable, tag, k, v)
            elseif statHandlers[tag] then
                statHandlers[tag](k, v)
            end
        end

        for _, t in pairs(increasePTable) do statHandlers[t[1]](t[2], t[3]) end
        for _, t in pairs(decreasePTable) do statHandlers[t[1]](t[2], t[3]) end

        for _, effect in ipairs(patternEffects) do
            local tag = effect[1]
            local args = { unpack(effect, 2) }
            if patternHandlers[tag] then patternHandlers[tag](unpack(args)) end
            if statHandlers[tag] then statHandlers[tag](unpack(args)) end
        end

        ::continue::
    end
end

return statsSystem
