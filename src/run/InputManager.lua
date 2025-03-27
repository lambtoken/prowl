local RM = require ('src.render.RenderManager'):getInstance()
local sceneManager = require("src.scene.SceneManager"):getInstance()

local InputManager = {}
InputManager.__index = InputManager

function InputManager:new(camera, currentMatch)
    local o = {
        camera = camera,
        currentMatch = currentMatch,
        selectedAnimal = nil,
        selectedAnimalDetails = nil,
        drag = false,
        dragX = 0,
        dragY = 0,
        dragMouseX = 0,
        dragMouseY = 0
    }
    setmetatable(o, InputManager)
    self.__index = self
    return o
end

function InputManager:mousepressed(x, y, btn)

    if self.selectedAnimal then
        if btn == 1 then
            
            local tile = self.currentMatch.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY)
            local steppable = self.currentMatch:isSteppable(self.hoveredTileX, self.hoveredTileY, self.selectedAnimal)
           
            if sceneManager.currentScene.pattern.isInsideMovePattern
               and steppable -- or (steppable and (#tile == 1 and tile[1] == self.selectedAnimal)) 
            then
                if self.hoveredTileX ~= self.selectedAnimal.position.x then
                    local facing = self.hoveredTileX - self.selectedAnimal.position.x > 0 and "right" or "left"
                    self.currentMatch.animationSystem:face(self.selectedAnimal, facing)
                end
                self.currentMatch.moveSystem:move(self.selectedAnimal, 'walk', self.hoveredTileX, self.hoveredTileY, true)
                self.currentMatch.teamManager:setLastActiveMob(self.selectedAnimal)
                self.selectedAnimal.state.pickedUp = false
                self.selectedAnimal = nil
            end
        end
    else 
        if btn == 1 then
            local currentTeam = self.currentMatch.teamManager.teams[self.currentMatch.teamManager.turnTeamId]
           
                local tileAnimal = self.currentMatch.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY, 'animal')[1]
                
                if tileAnimal then
                    sceneManager.currentScene.animalStats:loadAnimal(tileAnimal)
                end

                if not self.selectedAnimal and tileAnimal 
                and tileAnimal.state.currentTurnMoves < tileAnimal.stats.current.moves
                and tileAnimal.metadata.teamID == self.currentMatch.teamManager.turnTeamId
                and not self.currentMatch.moveSystem:isMoving(tileAnimal)
                and tileAnimal.state.current == "alive" 
                and currentTeam.agentType == 'player' then        
                    self.selectedAnimal = self.currentMatch.moveSystem:findByCoordinates(self.hoveredTileX, self.hoveredTileY, 'animal')[1]
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


    if btn == 2 then
        if self.selectedAnimal then
            self.selectedAnimal.state.pickedUp = false
            self.selectedAnimal = nil
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

    local x, y = self.camera:worldCoords(x, y)

    self.hoveredTileX = ((x / RM.tileSize) * RM.tileSize - 
        (x / RM.tileSize) * RM.tileSize % RM.tileSize) / RM.tileSize
    self.hoveredTileY = ((y / RM.tileSize) * RM.tileSize - 
        (y / RM.tileSize) * RM.tileSize % RM.tileSize) / RM.tileSize
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
