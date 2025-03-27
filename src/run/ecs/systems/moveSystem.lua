local Concord = require("libs.concord")
local RM = require('src.render.RenderManager'):getInstance()
local tween = require("libs.tween")
local pretty = require("libs.batteries.pretty")
local events = require("src.state.events"):getInstance()
local mobData = require("src.generation.mobs")
local objectData = require("src.generation.objects")
local gs = require("src.state.GameState"):getInstance()

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
        duration = 1
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
    
    attack = attack or false

    local position = entity.position

    if cancelPrev then moveSystem:snap(entity) end
    
    local relX = targetX - position.x
    local relY = targetY - position.y

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
        if entity.position.x == x and entity.position.y == y and entity.state.current == "alive" and typeCondition then
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


function moveSystem:getNearbyEntities(entity)
    local sources = {}

    for i = -1, 1 do
        for j = -1, 1 do
            if (i == 0) ~= (j == 0) then
                local x = entity.position.x + i
                local y = entity.position.y + j

                local potentialSources = self:findByCoordinates(x, y)
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
                mobData[src.metadata.species].passive.onTouched(gs.currentMatch, src, entity)
            end
        elseif src.metadata.type == 'object' then
            if objectData[src.metadata.objectName].passive and objectData[src.metadata.objectName].passive.onTouched then
                objectData[src.metadata.objectName].passive.onTouched(gs.currentMatch, src, entity)
            end
        end
    end
end


function moveSystem:handleMoved(entity)

    if entity.metadata.type == 'animal' then
        if mobData[entity.metadata.species].passive and mobData[entity.metadata.species].passive.onTouched then
            local nearbyEntities = self:getNearbyEntities(entity)
    
            for _, target in ipairs(nearbyEntities) do
                mobData[entity.metadata.species].passive.onTouched(gs.currentMatch, entity, target)
            end
        end
    
        self:handleTouched(entity)
    end

    if entity.metadata.type == 'object' then
        if objectData[entity.metadata.objectName].passive and objectData[entity.metadata.objectName].passive.onTouched then
            local nearbyEntities = self:getNearbyEntities(entity)
    
            for _, target in ipairs(nearbyEntities) do
                objectData[entity.metadata.objectName].passive.onTouched(gs.currentMatch, entity, target)
            end
        end
    
        self:handleTouched(entity)
    end
end

function moveSystem:handleOnStepped(entity)

    local tileObjects = self:findByCoordinates(entity.position.x, entity.position.y, 'object')

    if #tileObjects == 1 and tileObjects[1] ~= entity then
        local object = tileObjects[1]
        if objectData[object.metadata.objectName].passive and objectData[object.metadata.objectName].passive.onStepped then
            objectData[object.metadata.objectName].passive.onStepped(gs.currentMatch, entity, object)
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

        local forDeletion = {}

        local sumX = 0
        local sumY = 0

        for _, tween in ipairs(position.moveTweens) do
            tween.tween:update(dt)
            
            if not tween.tween:isComplete() then
                sumX = sumX + tween.x
                sumY = sumY + tween.y
            else
                -- position.prevX = position.lastStepX
                -- position.prevY = position.lastStepY
    
                position.lastStepX = position.lastStepX + tween.x
                position.lastStepY = position.lastStepY + tween.y
    
                self:handleMoved(entity)                
            
                self:handleOnStepped(entity)
    
                -- search for possible sources
                -- callback(matchState, target(entity), source)
    
                -- should change this later to go of when entity just enters the tile (last hover)
                if tween.attack then
                    events:emit("onStep", entity, tween.attack)
                end
    
                table.insert(forDeletion, _)
            end
        end

        if #forDeletion > 0 then
            for i = #forDeletion, 1, -1 do
                local tweenIndex = forDeletion[i]
                if position.moveTweens[tweenIndex].type == 'walk' then
                    entity.state.currentTurnMoves = entity.state.currentTurnMoves + 1
                end
                table.remove(position.moveTweens, tweenIndex)
            end
        end        

        if #position.moveTweens > 0 then
            position.dirX, position.dirY = calculateDirectionFromTweens(position)
        else
            position.dirX, position.dirY = 0, 0
        end

        local hoveredX = position.lastStepX + sumX
        local hoveredY = position.lastStepY + sumY

        --hover + event
        if position.dirX < -0.5 then
            position.x = math.floor(hoveredX + 0.5 - stepThreshold)
        elseif position.dirX > 0.5 then
            position.x = math.floor(hoveredX + 0.5 + stepThreshold)
        else
            position.x = math.floor(hoveredX + 0.5)
        end

        if position.dirY < -0.5 then
            position.y = math.floor(hoveredY + 0.5 - stepThreshold)
        elseif position.dirY > 0.5 then
            position.y = math.floor(hoveredY + 0.5 + stepThreshold)
        else
            position.y = math.floor(hoveredY + 0.5)
        end


        -- if position.x ~= position.lastStepX or position.y ~= position.lastStepY then
        --     events:emit("onHover", entity)
        --     events:emit("onHovered", entity, position.x, position.y)
            
        --     -- position.lastStepX = position.x
        --     -- position.lastStepY = position.y
        -- end

        position.screenX = hoveredX * RM.tileSize
        position.screenY = hoveredY * RM.tileSize


        --print(position.x, position.y, position.screenX, position.screenY)
        --print(position.x, " ", position.y)
        --print(position.screenX, " ", position.screenY)
        
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
        if #entity.position.moveTweens > 0 then
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
        if entity.metadata and entity.metadata.type == "animal" and entity.state.current == "alive" then
            for i = 1, select("#", ...) do
                local id = select(i, ...)
                if entity.metadata.teamID ~= id then
                    sumX = sumX + entity.position.x
                    sumY = sumY + entity.position.y
                    n = n + 1
                end 
            end 
        end
    end
    
    return math.floor(sumX / n), math.floor(sumY / n)
end

function moveSystem:removeAll(entity)
    entity.position.moveTweens = {}
end

return moveSystem