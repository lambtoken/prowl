local pretty = require "libs.batteries.pretty"
local aiManager = {}
aiManager.__index = aiManager

function aiManager:new(matchState)
    local o = {
        currentMatch = matchState
    }
    setmetatable(o, self)
    o.__index = self

    return o
end


local function splitTableByRange(tbl, left, right)
    local splitTable = {}

    for i = left, right do
        table.insert(splitTable, tbl[i])
    end

    return splitTable
end


function aiManager:ratingFormula(attacker, attackerX, attackerY, target)
    local atk = attacker.stats.current.atk
    local crit = attacker.stats.current.crit
    local ls = attacker.stats.current.lifeSteal
    local attackerMaxHp = attacker.stats.current.maxHp
    local attackerHp = attacker.stats.current.hp
    local def = target and target.stats.current.atk or 1
    local targetHp = target and target.stats.current.hp or 1

    local lsWeight = ls > 0 and (2 - attackerHp / attackerMaxHp) or 1
    local lethalBonus = targetHp / 10
    
    local averagePosX, averagePosY = self.currentMatch.moveSystem:getAveragePosition(attacker.metadata.teamID)
    local targetX = target and target.position.x or averagePosX
    local targetY = target and target.position.y or averagePosY

    local distanceToTarget = math.sqrt((targetX - attackerX) ^ 2 + (targetY - attackerY) ^ 2)
    print(distanceToTarget, attacker.metadata.species)
    print("avg: ", averagePosX, averagePosY)
    local distanceModifier = 1 / distanceToTarget
    
    local score = target and atk or 1 * (1 + crit) * lsWeight * (1 + ls) * (1 + distanceModifier) + lethalBonus - def / 20

    -- print("atk " .. atk .. "distance: " .. distanceToTarget .. "disMod: " .. distanceModifier, "pos " .. attackerX, attackerY, "score: ", score)

    return score
end


function aiManager:rateMoves(entity)
    
    local allPossibleMoves = {}

    local movePattern = entity.stats.currentPatterns.movePattern
    local attackPattern = entity.stats.currentPatterns.atkPattern

    for m_y, m_row in ipairs(movePattern) do
        for m_x, move in ipairs(m_row) do
            if move == 1 then
                local steppableX = entity.position.x + m_x - math.ceil(#movePattern[1] / 2)
                local steppableY = entity.position.y + m_y - math.ceil(#movePattern / 2)
                if self.currentMatch:isSteppable(steppableX, steppableY) then
                    for a_y, a_row in ipairs(attackPattern) do
                        for a_x, atk in ipairs(a_row) do
                            if atk == 1 then
                                local targetX = steppableX + a_x - math.ceil(#attackPattern[1] / 2)
                                local targetY = steppableY + a_y - math.ceil(#attackPattern / 2)
                                local targets = self.currentMatch.moveSystem:findByCoordinates(targetX, targetY)
                                for _, t in ipairs(targets) do
                                    if t.metadata.type == 'animal' and entity.metadata.teamID ~= t.metadata.teamID then
                                        local score = self:ratingFormula(entity, steppableX, steppableY, t)
                                        table.insert(allPossibleMoves, {entity = entity, target = t, score = score, x = steppableX, y = steppableY})
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if #allPossibleMoves == 0 then 
        for m_y, m_row in ipairs(movePattern) do
            for m_x, move in ipairs(m_row) do
                if move == 1 then
                    local steppableX = entity.position.x + m_x - math.ceil(#movePattern[1] / 2)
                    local steppableY = entity.position.y + m_y - math.ceil(#movePattern / 2)
                    if self.currentMatch:isSteppable(steppableX, steppableY) then
                        local score = self:ratingFormula(entity, steppableX, steppableY, nil)
                        table.insert(allPossibleMoves, {entity = entity, target = nil, score = score, x = steppableX, y = steppableY}) end
                    end
                end
            end
        end

    return allPossibleMoves
end


function aiManager:pickMove(moves, difficulty)
    assert(difficulty == "easy" or difficulty == "medium" or difficulty == "hard", "Invalid difficulty, got: " .. tostring(difficulty))
    assert(#moves > 0, "Provided empty table for moves!")

    if difficulty == "easy" then
        local random = math.random() < 0.2

        if random then
            return moves[math.random(#moves)]
        else
            local portion = splitTableByRange(moves, math.ceil(#moves / 3), math.ceil(#moves / 3 * 2))
            return portion[math.random(#portion)]
        end

    elseif difficulty == "medium" then
        local random = math.random() < 0.2

        if random then
            return moves[math.random(#moves)]
        else
            local leftIndex = #moves - math.max(1, math.floor(#moves * 0.3))
            local portion = splitTableByRange(moves, leftIndex, #moves)
            return portion[math.random(#portion)]
        end

    elseif difficulty == "hard" then
        local random = math.random() < 0.1

        if random then
            return moves[math.random(#moves)]
        end

        local leftIndex = #moves - math.max(1, math.floor(#moves * 0.1))
        local portion = splitTableByRange(moves, leftIndex, #moves)
        print("moves size: ".. #moves)
        print("portion size: " .. #portion)
        print("left index: ", leftIndex)

        for index, value in ipairs(portion) do
            print(value.score, value.x, value.y, value.entity.metadata.species)
        end

        return portion[math.random(#portion)]
        -- return portion[#portion]
    end
end

function aiManager:getMove(teamID)
    local allMoves = {}
    
    for _, e in ipairs(self.currentMatch.teamManager.teams[teamID].members) do
        if e.state.current == "alive" and self.currentMatch.stateSystem:hasActions(e) then
            for _, move in ipairs(self:rateMoves(e)) do
                table.insert(allMoves, move)
            end
        end
    end

    table.sort(allMoves, function(a, b)
        return a.score < b.score
    end)

    if #allMoves == 0 then
        return nil
    end

    local pickedMove = self:pickMove(allMoves, "hard")

    return pickedMove
end

return aiManager
