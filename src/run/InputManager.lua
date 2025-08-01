local RM = require ('src.render.RenderManager'):getInstance()
local sceneManager = require("src.scene.SceneManager"):getInstance()
local SoundManager = require("src.sound.SoundManager"):getInstance()

local InputManager = {}
InputManager.__index = InputManager

local mouseTypes = {
    default = 1,
    selectTile = 2,
}

function InputManager:new(camera, currentMatch)
    local o = {
        camera = camera,
        match = currentMatch,
        selectedAnimal = nil,
        selectedAnimalDetails = nil,
        drag = false,
        dragX = 0,
        dragY = 0,
        dragMouseX = 0,
        dragMouseY = 0,
        hoveredTileX = nil,
        hoveredTileY = nil,
        mouseType = mouseTypes.default,
        lastHoveredTileX = nil,
        lastHoveredTileY = nil,
        hoverTimer = 0,
        hoverDelay = 0.5,
        hoveredEntity = nil,
    }
    setmetatable(o, InputManager)
    self.__index = self
    return o
end

function InputManager:mousepressed(x, y, btn)
    if self.match.winnerId then
        return
    end

    if btn == 2 and self.selectedAnimal then
        self.selectedAnimal.state.pickedUp = false
        self.selectedAnimal = nil
        sceneManager.currentScene.animalStats:loadAnimal(nil)
    end
    
    if btn ~= 1 then
        return
    end

    if self.selectedAnimal then
        if self.match.teamManager.turnTeamId ~= self.selectedAnimal.team.teamId then
            return
        end
        
        local tile = self.match.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY)
        local steppable = self.match:isSteppable(self.hoveredTileX, self.hoveredTileY, self.selectedAnimal)
       
        if sceneManager.currentScene.pattern.isInsideMovePattern
            and steppable -- or (steppable and (#tile == 1 and tile[1] == self.selectedAnimal)) 
        then
            if self.hoveredTileX ~= self.selectedAnimal.position.x then
                local facing = self.hoveredTileX - self.selectedAnimal.position.x > 0 and "right" or "left"
                self.match.animationSystem:face(self.selectedAnimal, facing)
            end
            self.match.moveSystem:move(self.selectedAnimal, 'walk', self.hoveredTileX, self.hoveredTileY, true)
            self.match.teamManager:setLastActiveMob(self.selectedAnimal)
            self.selectedAnimal.state.pickedUp = false
            self.selectedAnimal = nil
        end
    else 
        local currentTeam = self.match.teamManager.teams[self.match.teamManager.turnTeamId]
    
        local tileAnimal = self.match.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY, 'animal')[1]
        
        if tileAnimal then
            SoundManager:playSound("clicktech3")
            sceneManager.currentScene.animalStats:loadAnimal(tileAnimal)
            sceneManager.currentScene:removeTooltip()
        end

        if not self.selectedAnimal and tileAnimal 
        and tileAnimal.state.currentTurnMoves < tileAnimal.stats.current.moves
        and tileAnimal.team.teamId == self.match.teamManager.turnTeamId
        and not self.match.moveSystem:isMoving(tileAnimal)
        and tileAnimal.state.alive 
        and currentTeam.agentType == 'player' then        
            self.selectedAnimal = self.match.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY, 'animal')[1]
            self.selectedAnimal.state.pickedUp = true
            self.hangingPiece:resetAngularVelocity()
            self.hangingPiece:setAnimalSprite(self.selectedAnimal.metadata.name)
            self.patternDisplay:loadAnimal(self.selectedAnimal)
           
            if sceneManager.currentScene.pattern then
                sceneManager.currentScene.pattern:preparePatterns()
            end
            
            self.hoveredEntity = nil
            self.hoverTimer = 0
        else
            self.drag = true
            self.dragX, self.dragY = self.camera:worldCoords(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
            self.dragMouseX, self.dragMouseY = x, y
        end

        if not tileAnimal then
            sceneManager.currentScene.animalStats:loadAnimal(nil)
        end
    end
end

function InputManager:mousereleased(x, y, btn)
    -- TODO: add picking and releasing like in tft mechanic as well
    if btn == 1 then
        self.drag = false
    end
end

function InputManager:mousemoved(x, y)
    if self.drag then
        local dx = x - self.dragMouseX
        local dy = y - self.dragMouseY
        
        local newCamX = self.dragX - dx
        local newCamY = self.dragY - dy
        
        local boundary = RM.tileSize * 2
        local mapWidth = self.match.width * RM.tileSize
        local mapHeight = self.match.height * RM.tileSize
        
        local clampedX = math.max(-boundary, math.min(mapWidth + boundary, newCamX))
        local clampedY = math.max(-boundary, math.min(mapHeight + boundary, newCamY))
        
        self.camera:lookAt(clampedX, clampedY)
    end
    
    self.hoveredTileX, self.hoveredTileY = self:getHoveredTileCoordinates()

    local tile = self.match.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY)

    if (self.hoveredTileX ~= self.lastHoveredTileX or self.hoveredTileY ~= self.lastHoveredTileY) then -- and #tile > 0 then
        if not self.selectedAnimal then
            -- SoundManager:playSound("softclick2") -- idk
            SoundManager:playSound("pclick5")
            if tile and tile[1] then
                self.hoveredEntity = tile[1]
                self.hoverTimer = 0
                sceneManager.currentScene:removeTooltip()
            else
                self.hoveredEntity = nil
                self.hoverTimer = 0
                sceneManager.currentScene:removeTooltip()
            end
        elseif sceneManager.currentScene.pattern.isInsideMovePattern then
            SoundManager:playSound("softclick2")

            -- SoundManager:playSound("softclick3") -- maybe not..
        end
    end
    
    self.lastHoveredTileX = self.hoveredTileX
    self.lastHoveredTileY = self.hoveredTileY
end

function InputManager:getHoveredTileCoordinates()
    local screenX, screenY = love.mouse.getPosition()
    local virtualX, virtualY = RM:mouseToVirtual(screenX, screenY)
    local x, y = self.camera:worldCoords(virtualX, virtualY, 0, 0, RM.windowWidth, RM.windowHeight)
    local tileX = math.floor(x / RM.tileSize)
    local tileY = math.floor(y / RM.tileSize)
    return tileX, tileY
end

function InputManager:setHangingPiece(hp)
    self.hangingPiece = hp
end

function InputManager:setPatternDisplay(pd)
    self.patternDisplay = pd
end

function InputManager:update(dt)
    if self.hoveredEntity then
        self.hoverTimer = self.hoverTimer + dt
        
        if self.hoverTimer >= self.hoverDelay and not sceneManager.currentScene.tooltip then
            sceneManager.currentScene:createTooltip(self.hoveredEntity)
        end
    else
        self.hoverTimer = 0
    end
end

function InputManager:keypressed(key)
end

return InputManager