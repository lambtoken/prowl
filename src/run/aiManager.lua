local pretty = require "libs.batteries.pretty"
local aiManager = {}
aiManager.__index = aiManager

function aiManager:new(matchState)
    local o = {
        match = matchState
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
    
    local averagePosX, averagePosY = self.match.moveSystem:getAveragePosition(attacker.metadata.teamId)
    local targetX = target and target.position.x or averagePosX
    local targetY = target and target.position.y or averagePosY

    local distanceToTarget = math.sqrt((targetX - attackerX) ^ 2 + (targetY - attackerY) ^ 2)
    --print(distanceToTarget, attacker.metadata.species)
    --print("avg: ", averagePosX, averagePosY)
    local distanceModifier = 1 / distanceToTarget
    
    local score = target and atk or 1 * (1 + crit) * lsWeight * (1 + ls) * (1 + distanceModifier) + lethalBonus - def / 20

    -- print("atk " .. atk .. "distance: " .. distanceToTarget .. "disMod: " .. distanceModifier, "pos " .. attackerX, attackerY, "score: ", score)

    return score
end


-- Helper: get all possible positions the player can move to next turn
function aiManager:getPossiblePlayerPositions()
    -- Assume player is always team 1, first member
    local playerTeam = self.match.teamManager.teams[1]
    if not playerTeam or #playerTeam.members == 0 then return {} end
    local player = playerTeam.members[1]
    if not player or not player.state.alive then return {} end
    local movePattern = player.stats.currentPatterns.movePattern
    local positions = {}
    for m_y, m_row in ipairs(movePattern) do
        for m_x, move in ipairs(m_row) do
            if move == 1 then
                local px = player.position.x + m_x - math.ceil(#movePattern[1] / 2)
                local py = player.position.y + m_y - math.ceil(#movePattern / 2)
                if self.match:isSteppable(px, py, player) then
                    table.insert(positions, {x = px, y = py})
                end
            end
        end
    end
    -- Always include current position as a fallback
    table.insert(positions, {x = player.position.x, y = player.position.y})
    return positions
end

function aiManager:rateMoves(entity)
    local allPossibleMoves = {}
    local movePattern = entity.stats.currentPatterns.movePattern
    local attackPattern = entity.stats.currentPatterns.atkPattern

    -- Get predicted player positions
    local predictedPlayerPositions = self:getPossiblePlayerPositions()
    local playerTeamId = 1

    for m_y, m_row in ipairs(movePattern) do
        for m_x, move in ipairs(m_row) do
            if move == 1 then
                local steppableX = entity.position.x + m_x - math.ceil(#movePattern[1] / 2)
                local steppableY = entity.position.y + m_y - math.ceil(#movePattern / 2)
                if self.match:isSteppable(steppableX, steppableY) then
                    for a_y, a_row in ipairs(attackPattern) do
                        for a_x, atk in ipairs(a_row) do
                            if atk == 1 then
                                local targetX = steppableX + a_x - math.ceil(#attackPattern[1] / 2)
                                local targetY = steppableY + a_y - math.ceil(#attackPattern / 2)
                                -- Check if this attack position matches any predicted player position
                                local willHitPlayer = false
                                for _, pos in ipairs(predictedPlayerPositions) do
                                    if pos.x == targetX and pos.y == targetY then
                                        willHitPlayer = true
                                        break
                                    end
                                end
                                local targets = self.match.moveSystem:findByCoordinates(targetX, targetY)
                                for _, t in ipairs(targets) do
                                    if t.metadata.type == 'animal' and entity.metadata.teamId ~= t.metadata.teamId then
                                        local score = self:ratingFormula(entity, steppableX, steppableY, t)
                                        -- Boost score if this move can hit a predicted player position
                                        if willHitPlayer and t.metadata.teamId == playerTeamId then
                                            score = score + 1000 -- Large bonus to prioritize hitting where player can go
                                        end
                                        table.insert(allPossibleMoves, {entity = entity, target = t, score = score, x = steppableX, y = steppableY})
                                    end
                                end
                                -- If no target but can hit predicted player position, add a move anyway
                                if willHitPlayer then
                                    local score = self:ratingFormula(entity, steppableX, steppableY, nil) + 900
                                    table.insert(allPossibleMoves, {entity = entity, target = nil, score = score, x = steppableX, y = steppableY})
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
                    if self.match:isSteppable(steppableX, steppableY) then
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
            print("move portion: ", #portion)
            return portion[math.random(#portion)]
        end

    elseif difficulty == "hard" then
        local random = math.random() < 0.1

        if random then
            return moves[math.random(#moves)]
        end

        local leftIndex = #moves - math.max(1, math.floor(#moves * 0.1))
        local portion = splitTableByRange(moves, leftIndex, #moves)
        -- print("moves size: ".. #moves)
        -- print("portion size: " .. #portion)
        -- print("left index: ", leftIndex)

        -- for index, value in ipairs(portion) do
        --     print(value.score, value.x, value.y, value.entity.metadata.species)
        -- end

        return portion[math.random(#portion)]
        -- return portion[#portion]
    end
end

function aiManager:getMoves(teamID, amount)
    local allMoves = {}

    for _, e in ipairs(self.match.teamManager.teams[teamID].members) do
        if e.state.alive and self.match.stateSystem:hasActions(e) then
            for _, move in ipairs(self:rateMoves(e)) do
                table.insert(allMoves, move)
            end
        end
    end

    table.sort(allMoves, function(a, b)
        return a.score < b.score
    end)

    if #allMoves == 0 then
        return {}
    end

    local picked = {}
    local usedEntities = {}

    for i = 1, amount do
        local pickedMove = nil

        for j = #allMoves, 1, -1 do
            local move = allMoves[j]
            local alreadyUsed = usedEntities[move.entity]

            local overlaps = false
            for _, p in ipairs(picked) do
                if p.x == move.x and p.y == move.y then
                    overlaps = true
                    break
                end
            end

            if not alreadyUsed and not overlaps then
                local entityMoves = {}
                for _, m in ipairs(allMoves) do
                    if m.entity == move.entity then
                        local overlap = false
                        for _, p in ipairs(picked) do
                            if p.x == m.x and p.y == m.y then
                                overlap = true
                                break
                            end
                        end
                        if not overlap then
                            table.insert(entityMoves, m)
                        end
                    end
                end

                if #entityMoves > 0 then
                    pickedMove = self:pickMove(entityMoves, "hard")
                    usedEntities[move.entity] = true
                    break
                end
            end
        end

        if pickedMove then
            table.insert(picked, pickedMove)
        else
            break
        end
    end

    return picked
end


return aiManager
