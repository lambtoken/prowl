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
    }
    setmetatable(o, InputManager)
    self.__index = self
    return o
end

function InputManager:mousepressed(x, y, btn)

    -- check right click first
    if btn == 2 and self.selectedAnimal then
        self.selectedAnimal.state.pickedUp = false
        self.selectedAnimal = nil
        sceneManager.currentScene.animalStats:loadAnimal(nil)
    end
    
    if btn ~= 1 then
        return
    end

    if self.selectedAnimal then
        
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
            sceneManager.currentScene.animalStats:loadAnimal(tileAnimal)
        end

        if not self.selectedAnimal and tileAnimal 
        and tileAnimal.state.currentTurnMoves < tileAnimal.stats.current.moves
        and tileAnimal.metadata.teamId == self.match.teamManager.turnTeamId
        and not self.match.moveSystem:isMoving(tileAnimal)
        and tileAnimal.state.alive 
        and currentTeam.agentType == 'player' then        
            self.selectedAnimal = self.match.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY, 'animal')[1]
            self.selectedAnimal.state.pickedUp = true
            self.hangingPiece:resetAngularVelocity()
            self.hangingPiece:setAnimalSprite(self.selectedAnimal.metadata.species)
            self.patternDisplay:loadAnimal(self.selectedAnimal) 
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
    -- add picking and releasing like in tft mechanic as well
    if btn == 1 then
        self.drag = false
    end
end

function InputManager:mousemoved(x, y)
    if self.drag then
        self.camera:lookAt(self.dragX - (x - self.dragMouseX), self.dragY - (y - self.dragMouseY))
    end

    local worldX, worldY = self.camera:worldCoords(x, y)
    
    -- Calculate tile coordinates by dividing by tile size and flooring
    self.hoveredTileX = math.floor(worldX / RM.tileSize)
    self.hoveredTileY = math.floor(worldY / RM.tileSize)

    local tile = self.match.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY)

    -- Check if we moved to a new tile AND there are entities on that tile
    if (self.hoveredTileX ~= self.lastHoveredTileX or self.hoveredTileY ~= self.lastHoveredTileY) and #tile > 0 then
        if not self.selectedAnimal then
            SoundManager:playSound("softclick2")
        elseif sceneManager.currentScene.pattern.isInsideMovePattern then
            SoundManager:playSound("softclick3")
        end
    end
    
    self.lastHoveredTileX = self.hoveredTileX
    self.lastHoveredTileY = self.hoveredTileY
end

function InputManager:getHoveredTileCoordinates()
    -- Calculate hovered tile coordinates
    local x, y = self.camera:worldCoords(love.mouse.getX(), love.mouse.getY())
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

function InputManager:keypressed(key)
end

return InputManager
