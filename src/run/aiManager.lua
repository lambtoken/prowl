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
    
    local averagePosX, averagePosY = self.match.moveSystem:getAveragePosition(attacker.team.teamId)
    local targetX = target and target.position.x or averagePosX
    local targetY = target and target.position.y or averagePosY

    local distanceToTarget = math.sqrt((targetX - attackerX) ^ 2 + (targetY - attackerY) ^ 2)
    --print(distanceToTarget, attacker.metadata.name)
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
                                    if t.metadata.type == 'animal' and entity.team.teamId ~= t.team.teamId then
                                        local score = self:ratingFormula(entity, steppableX, steppableY, t)
                                        -- Boost score if this move can hit a predicted player position
                                        if willHitPlayer and t.team.teamId == playerTeamId then
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
        local random = math.random() < 0.4

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
        --     print(value.score, value.x, value.y, value.entity.metadata.name)
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

    if #allMoves == 0 then
        return {}
    end

    local picked = {}
    local usedEntities = {}

    for i = 1, amount do
        -- Instead of sorting + filtering, just pick from allMoves

        local randomMove = #allMoves > 0 and self:pickMove(allMoves, "medium") or nil

        if randomMove then
            table.insert(picked, randomMove)
            usedEntities[randomMove.entity] = true

            -- Optionally remove moves by the same entity or overlapping positions
            for j = #allMoves, 1, -1 do
                if allMoves[j].entity == randomMove.entity or
                   (allMoves[j].x == randomMove.x and allMoves[j].y == randomMove.y) then
                    table.remove(allMoves, j)
                end
            end
        else
            break
        end
    end

    return picked
end

-- Returns a table: { [entity] = { main = move, alt = move } }
function aiManager:getMainAndAltMoves(teamID, amount, difficulty)
    difficulty = difficulty or "easy" -- default to medium if not specified
    local entityMoves = {}
    
    -- First, collect all possible moves for each entity
    for _, e in ipairs(self.match.teamManager.teams[teamID].members) do
        if e.state.alive and self.match.stateSystem:hasActions(e) then
            local moves = self:rateMoves(e)
            if #moves > 0 then
                -- Sort moves by score descending for easier processing
                table.sort(moves, function(a, b)
                    if a.score ~= b.score then return a.score > b.score end
                    if a.x ~= b.x then return a.x < b.x end
                    return a.y < b.y
                end)
                
                -- Use pickMove to select main and alt moves based on difficulty
                local mainMove = self:pickMove(moves, difficulty)
                
                -- For alt move, remove the main move and pick again
                local altMoves = {}
                for _, move in ipairs(moves) do
                    if move.x ~= mainMove.x or move.y ~= mainMove.y then
                        table.insert(altMoves, move)
                    end
                end
                
                local altMove = #altMoves > 0 and self:pickMove(altMoves, difficulty) or mainMove
                
                table.insert(entityMoves, { 
                    entity = e,
                    main = mainMove, 
                    alt = altMove 
                })
            end
        end
    end

    -- Now select which entities will actually move (up to 'amount')
    local pickedMoves = {}
    
    -- Sort entity moves by their main move score (descending)
    table.sort(entityMoves, function(a, b)
        return a.main.score > b.main.score
    end)
    
    -- Select top 'amount' moves, avoiding position conflicts
    local usedPositions = {}
    for i = 1, math.min(amount, #entityMoves) do
        -- Try to find a move that doesn't conflict with already picked positions
        local selected = nil
        for j, movePair in ipairs(entityMoves) do
            local posKey = movePair.main.x .. "," .. movePair.main.y
            if not usedPositions[posKey] then
                selected = movePair
                usedPositions[posKey] = true
                table.remove(entityMoves, j)
                break
            end
        end
        
        -- If all moves conflict, just pick the highest scoring one
        if not selected and #entityMoves > 0 then
            selected = entityMoves[1]
            table.remove(entityMoves, 1)
        end
        
        if selected then
            pickedMoves[selected.entity] = { 
                main = selected.main, 
                alt = selected.alt 
            }
        end
    end

    return pickedMoves
end

return aiManager
