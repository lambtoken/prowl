local Concord = require("libs.concord")
local RM = require('src.render.RenderManager'):getInstance()
local tween = require("libs.tween")
local pretty = require("libs.batteries.pretty")
local events = require("src.state.events"):getInstance()
local mobData = require("src.generation.mobs")
local objectData = require("src.generation.objects")
local itemData = require("src.generation.items")
local markData = require("src.generation.marks")
local gs = require("src.state.GameState"):getInstance()
local on = require("src.run.ecs.on")

local CELLSIZE = RM.tileSize

local stepThreshold = 0.25


local function calculateDirectionFromTweens(position)
    local totalDX, totalDY = 0, 0
    
    for _, tweenData in ipairs(position.moveTweens) do
        local dx = tweenData.targetX - tweenData.startX
        local dy = tweenData.targetY - tweenData.startY
        
        -- Normalize
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then
            dx, dy = dx / length, dy / length
        end
        
        -- Sum
        totalDX = totalDX + dx
        totalDY = totalDY + dy
    end
    
    -- Normalize the resultant direction vector
    local totalLength = math.sqrt(totalDX * totalDX + totalDY * totalDY)
    if totalLength > 0 then
        return totalDX / totalLength, totalDY / totalLength
    else
        return 0, 0 -- No movement
    end
end

local MOVES = {
    walk = {
        func = 'inOutQuint',
        duration = 1
    },
    knockback = {
        func = 'outSine',
        duration = 1.5
    },
    slide = {
        func = 'linear',
        duration = 4
    },
    snap = {
        func = 'linear',
        duration = 0.2
    },
    displace = {
        func = 'outQuad',
        duration = 1.2
    },
    tp = {
        func = 'linear',
        duration = 0.2
    }
}

local moveSystem = Concord.system({pool = {position}}) -- Define a System that takes all Entities with a position and texture Component

moveSystem.onTouchRegisters = {}

function moveSystem:init()
    events:on("registerOnTouched", function(entity, callback) 
        table.insert(self.onTouchRegisters, {entity = entity, callback = callback})
    end)
end

function moveSystem:snap(entity)
    
    local position = entity.position

    position.moveTweens = {}
    local targetX = math.ceil(position.screenX / CELLSIZE) * CELLSIZE
    local targetY = math.floor(position.screenY / CELLSIZE) * CELLSIZE

    --position.snapTween = tween.new(MOVES['snap'].duration, position, {screenX = targetX, screenY = targetY}, MOVES['snap'].func)

    local newTween = tween.new(MOVES['snap'].duration, position, {screenX = targetX, screenY = targetY}, MOVES['snap'].func)

    table.insert(position.moveTweens, {
        tween = newTween, 
        startX = position.screenX, 
        startY = position.screenY, 
        targetX = targetX, 
        targetY = targetY
      })

end


function moveSystem:setPosition(entity, x, y)
    entity.position.x = x
    entity.position.y = y
    entity.position.prevX = x
    entity.position.prevY = y
    entity.position.lastStepX = x
    entity.position.lastStepY = y
    entity.position.screenX = x * RM.tileSize
    entity.position.screenY = y * RM.tileSize
end


function moveSystem:move(entity, type, targetX, targetY, attack, cancelPrev)
    -- Consume 1 energy for basic moves 
    -- VIBE
    if type == "walk" and entity.stats and entity.stats.energy then
        if entity.stats.energy > 0 then
            entity.stats.energy = entity.stats.energy - 1
        end
    end
    
    if type == "walk" then
        on("onMove", gs.match, entity)
    end
    
    entity.position.attack = attack or entity.position.attack
    entity.position.step = true

    attack = attack or false

    local position = entity.position

    if cancelPrev then moveSystem:snap(entity) end

    local destX, destY = self:getDestination(entity)
    
    local relX = targetX - destX
    local relY = targetY - destY

    local newTween = {                           
        type = type,
        tween = nil,
        x = 0,
        y = 0,
        startX = position.x,
        startY = position.y,
        targetX = targetX,
        targetY = targetY,
        lengthX = relX, -- we can use this to check for the final step                          
        lengthY = relY,
        attack = attack
    }

    newTween.tween = tween.new(MOVES[type].duration, newTween, {x = relX, y = relY}, MOVES[type].func)
    table.insert(position.moveTweens, newTween)

end

function moveSystem:findByCoordinates(x, y, type)
    
    local entities = {}
    
    for _, entity in ipairs(self.pool) do
        local typeCondition = not type or entity.metadata.type == type
        if entity.position.x == x and entity.position.y == y and entity.state and entity.state.alive and typeCondition then
            table.insert(entities, entity)
        end
    end

    return entities
end


function moveSystem:findInSquare(x, y, width, type)

    local entities = {}

    local range = math.floor(width / 2)

    for i = -range, range do
        for j = -range, range do
            if not (i == 0 and j == 0) then
                local tileEntities = self:findByCoordinates(x + i, y + j, type)

                for i, entity in ipairs(tileEntities) do
                    table.insert(entities, entity) 
                end
            end
        end
    end

    return entities
    
end

function moveSystem:getTouching(x, y, type)

    local entities = {}

    for i = -1, 1 do
        for j = -1, 1 do
            if i == 0 or j == 0 then
                local tileEntities = self:findByCoordinates(x + i, y + j, type)

                for i, entity in ipairs(tileEntities) do
                    table.insert(entities, entity) 
                end
            end
        end
    end

    return entities
    
end


function moveSystem:getNearbyEntities(entity, type)
    local sources = {}

    for i = -1, 1 do
        for j = -1, 1 do
            if (i == 0) ~= (j == 0) then
                local x = entity.position.x + i
                local y = entity.position.y + j

                local potentialSources = self:findByCoordinates(x, y, type)
                if #potentialSources > 0 then
                    table.move(potentialSources, 1, #potentialSources, #sources + 1, sources)
                end
            end
        end
    end

    return sources
end


function moveSystem:handleTouched(entity)
    local nearbyEntities = self:getNearbyEntities(entity)

    -- trigger effects for nearby mobs
    for _, src in ipairs(nearbyEntities) do
        if src.metadata.type == 'animal' then
            if mobData[src.metadata.species].passive and mobData[src.metadata.species].passive.onTouched then
                mobData[src.metadata.species].passive.onTouched(gs.match, src, entity)
            end

            for index, item in ipairs(src.inventory.items) do
                local itemDef = itemData[item.name]
                if itemDef.passive and itemDef.passive.onTouched then
                    itemDef.passive.onTouched(gs.match, src, entity)
                end
            end
            
        elseif src.metadata.type == 'object' then
            if objectData[src.metadata.objectName].passive and objectData[src.metadata.objectName].passive.onTouched then
                objectData[src.metadata.objectName].passive.onTouched(gs.match, src, entity)
            end
        end
    end
end


function moveSystem:handleMoved(entity)

    if not entity.state.alive then
        return
    end

    if entity.metadata.type == 'animal' then
        if mobData[entity.metadata.species].passive and mobData[entity.metadata.species].passive.onTouched then
            local nearbyEntities = self:getNearbyEntities(entity)
    
            for _, target in ipairs(nearbyEntities) do
                mobData[entity.metadata.species].passive.onTouched(gs.match, entity, target)
            end
        end
    
        self:handleTouched(entity)
    end

    if entity.metadata.type == 'object' then
        if objectData[entity.metadata.objectName].passive and objectData[entity.metadata.objectName].passive.onTouched then
            local nearbyEntities = self:getNearbyEntities(entity)
    
            for _, target in ipairs(nearbyEntities) do
                objectData[entity.metadata.objectName].passive.onTouched(gs.match, entity, target)
            end
        end
    
        self:handleTouched(entity)
    end
end

function moveSystem:handleOnStepped(entity)

    if not entity.state.alive then
        return
    end

    local tileObjects = self:findByCoordinates(entity.position.x, entity.position.y, 'object')
    local tileMarks = self:findByCoordinates(entity.position.x, entity.position.y, 'mark')

    if #tileObjects == 1 and tileObjects[1] ~= entity then
        local object = tileObjects[1]
        if objectData[object.metadata.objectName].passive and objectData[object.metadata.objectName].passive.onStepped then
            objectData[object.metadata.objectName].passive.onStepped(gs.match, entity, object)
        end
    end

    for _, mark in ipairs(tileMarks) do
        if markData[mark.metadata.markName].passive and markData[mark.metadata.markName].passive.onStepped then
            markData[mark.metadata.markName].passive.onStepped(gs.match, entity, mark)
        end
    end
end


function moveSystem:update(dt)
    
    for _, entity in ipairs(self.pool) do
        local state = entity.state
        
        -- if state.current == "dead" then
        --     goto continue
        -- end

        local position = entity.position

        if position.customMove then
            position.customMove(entity, dt)
            position.screenX = position.x * RM.tileSize
            position.screenY = position.y * RM.tileSize
            goto continue
        end

        local sumX = 0
        local sumY = 0

        for i = #position.moveTweens, 1, -1 do
            local tween = position.moveTweens[i]

            tween.tween:update(dt)
            
            if not tween.tween:isComplete() then
                sumX = sumX + tween.x
                sumY = sumY + tween.y
            else    
                position.lastStepX = position.lastStepX + tween.x
                position.lastStepY = position.lastStepY + tween.y

                if position.moveTweens[i].type == 'walk' then
                    entity.state.currentTurnMoves = entity.state.currentTurnMoves + 1
                end

                table.remove(position.moveTweens, i)
            end
        end

        if #position.moveTweens > 0 then
            position.dirX, position.dirY = calculateDirectionFromTweens(position)
        else
            position.dirX, position.dirY = 0, 0
        end

        local hoveredX = position.lastStepX + sumX
        local hoveredY = position.lastStepY + sumY

        local newPosX
        local newPosY

        if position.dirX < -0.5 then
            newPosX = math.floor(hoveredX + 0.5 - stepThreshold)
        elseif position.dirX > 0.5 then
            newPosX = math.floor(hoveredX + 0.5 + stepThreshold)
        else
            newPosX = math.floor(hoveredX + 0.5)
        end

        position.lastPositionX = position.x

        if position.dirY < -0.5 then
            newPosY = math.floor(hoveredY + 0.5 - stepThreshold)
        elseif position.dirY > 0.5 then
            newPosY = math.floor(hoveredY + 0.5 + stepThreshold)
        else
            newPosY = math.floor(hoveredY + 0.5)
        end

        position.lastPositionY = position.y


        if newPosX ~= position.lastPositionX or newPosY ~= position.lastPositionY then
            events:emit("onHover", entity)
            --onHoverAny
            events:emit("onHovered", entity, position.x, position.y)             
            --onHoveredAny
        end

        position.screenX = hoveredX * RM.tileSize
        position.screenY = hoveredY * RM.tileSize

        position.x = newPosX
        position.y = newPosY

        if #entity.position.moveTweens == 0 and entity.position.step then
            self:handleMoved(entity)
            
            self:handleOnStepped(entity)

            if entity.state.alive then
                events:emit("onStep", entity, entity.position.attack)
            end

            entity.position.step = false
            entity.position.attack = false
        end
        
        -- if position.snapTween ~= nil then
        --     print(dt)
        --     if position.snapTween:update(dt) then
        --         position.snapTween = nil
        --     end
        -- end 

        ::continue::

    end
end

function moveSystem:isMoving(entity)
    if #entity.position.moveTweens > 0 then
        return true
    end
    return false
end

function moveSystem:allMovesDone()
    for _, entity in ipairs(self.pool) do
        if #entity.position.moveTweens > 0 or entity.position.customMove then
            return false
        end
    end
    return true
end

-- pass in team ids to exclude
function moveSystem:getAveragePosition(...)
    
    local sumX = 0
    local sumY = 0
    local n = 0
    for _, entity in ipairs(self.pool) do
        if entity.metadata and entity.metadata.type == "animal" and entity.state.alive then
            for i = 1, select("#", ...) do
                local id = select(i, ...)
                if entity.metadata.teamId ~= id then
                    sumX = sumX + entity.position.x
                    sumY = sumY + entity.position.y
                    n = n + 1
                end 
            end 
        end
    end
    
    return math.floor(sumX / n), math.floor(sumY / n)
end

function moveSystem:getNearestEntity(entity, type, teamID)
    local nearestEntity = nil
    local nearestDistance = 1000000

    for _, otherEntity in ipairs(self.pool) do

        if otherEntity.state and not otherEntity.state.alive then
            goto continue
        end

        if otherEntity.metadata and otherEntity.metadata.type == type then
            
            if teamID and otherEntity.metadata.teamId == teamID then
                goto continue
            end

            -- use squared distance to avoid sqrt
            local distance = (otherEntity.position.x - entity.position.x)^2 + (otherEntity.position.y - entity.position.y)^2
            if distance < nearestDistance then
                nearestDistance = distance
                nearestEntity = otherEntity
            end

        end
        ::continue::
    end

    return nearestEntity
end

function moveSystem:getDestination(entity)
    local sumX = 0
    local sumY = 0
    for index, tween in ipairs(entity.position.moveTweens) do
        sumX = sumX + tween.lengthX
        sumY = sumY + tween.lengthY
    end

    return sumX + entity.position.lastStepX, sumY + entity.position.lastStepY
end

function moveSystem:removeAll(entity)
    entity.position.moveTweens = {}
    entity.position.step = false
end

return moveSystem