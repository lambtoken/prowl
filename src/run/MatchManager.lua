local class = require 'libs.middleclass'
local Concord = require "libs.concord"
local fsm = require "libs.batteries.state_machine"
local pretty = require "libs.batteries.pretty"

local RM = require ('src.render.RenderManager'):getInstance()
local TeamManager = require 'src.run.TeamManager'
local animalData = require 'src.generation.mobs'
local EventManager = require "src.state.events"
local EntityFactory = require "src.run.EntityFactory"
local matchTerrain = require "src.generation.matchTerrain"
local aiManager = require "src.run.aiManager"
local stageMobAmount = require "src.generation.stageMobAmount"
local matchMobRates  = require "src.generation.matchMobRates"
local flowerData  = require "src.generation.flowers"
local pickLimited = require "src.generation.functions.pickLimited"
local SceneManager = require("src.scene.SceneManager"):getInstance()
local SoundManager = require("src.sound.SoundManager"):getInstance()
local matchObjectRates = require "src.generation.matchObjectRates"
local stageObjectAmount = require "src.generation.stageObjectAmount"
local gs = require("src.state.GameState"):getInstance()
local shimmerShader = love.graphics.newShader(require('src.render.shaders.shimmer_shader'))
local noiseShader = love.graphics.newShader(require('src.render.shaders.noise_shader'))
local getRandomItems= require('src.generation.functions.getRandomItems')
local stageMobItems = require('src.generation.stageMobItems')
local stageMobLevels = require('src.generation.stageMobLevels')
-- local stageMarkAmount = require('src.generation.stageMarkAmount')
local matchMarkRates = require('src.generation.matchMarkRates')
local rng = require "src.utility.rng"

local MatchManager = class("MatchManager")

function MatchManager:initialize()

    self.matchNode = nil
    self.width = 6
    self.height = 6
    self.teams = {}
    self.board = {
        terrain = {},
        decorations = {},
        objects = {}
    }

    self:init_ecs()

    self.eventManager = EventManager:getInstance()
    
    noiseShader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
end

function MatchManager:init()
    self.rng = rng:new(self.seed)
    self.rng:addGenerator("combat")
    self.rng:addGenerator("terrainGen")
    self.rng:addGenerator("mobGen")
    self.rng:addGenerator("objGen")

    self:removeEntitiesFromTheWorld()
    self:init_ecs()
    self:init_state_machine()
    self.winnerId = nil
    self.teamManager = TeamManager:new(self)
    self.teamManager:load()
    self.aiManager = aiManager:new(self)
end

function MatchManager:init_state_machine()
    self.states = fsm({
        playing = {
            instance = self,

            enter = function(s) 
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        result = {
            instance = self,

            enter = function(s)
                s.sceneTimer = 0
                s.sceneTime = 0
                s.timerFlag = false
                if s.instance.winnerId == 1 then
                    SoundManager:playSound('victory')
                else
                    SoundManager:playSound('loss')
                end
            end,
            
            update = function(s, dt) 
                s.sceneTimer = s.sceneTimer + dt
                
                if s.sceneTimer >= s.sceneTime and s.timerFlag == false then
                   
                    -- generate Items to gamestate
                    -- change scene to pick Item Scene
                    
                    if s.instance.winnerId == 1 then
                        SceneManager:switchScene("itemSelectNew")
                    else
                        gs.run:decreaseHealth()
                        if gs.run.runHealth > 0 then
                            SceneManager:switchScene("runMap")
                        else
                            gs.run:setOutcome()
                            SceneManager:switchScene("runEnd")
                        end
                    end
                    
                    s.timerFlag = true
                end

            end,

            draw = function(s) 
                love.graphics.print(s.instance.winnerId == 1 and "You won" or "You lost", 0, 0)
            end,
            
            exit = function() 
            end
        }
    }, "playing")

    self.states:set_state("playing")

    self.phase = fsm({
        stand_by_phase = {
            instance = self,

            -- onStandby event
            -- buffs/debuffs
            -- disabling, defensive
            -- dot
            -- passives
            -- phase starts on enter time of sliding text

            enter = function(s) 
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        main_phase = {
            instance = self,

            enter = function(s) 
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        end_phase = {
            instance = self,

            enter = function(s) 
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        }
    }, "stand_by")

    self.phase:set_state("stand_by_phase")
end

function MatchManager:init_ecs()
    self.ecs = Concord.world()

    EntityFactory:loadComponents()

    self.__systems = EntityFactory:loadSystems()

    self.ecs:addSystems(
        self.__systems.animationSystem,
        self.__systems.renderSystem,
        self.__systems.moveSystem,
        self.__systems.combatSystem,
        self.__systems.crowdControlSystem,
        self.__systems.itemSystem,
        self.__systems.statsSystem,
        self.__systems.timerSystem,
        self.__systems.buffDebuffSystem,
        self.__systems.statusEffectSystem,
        self.__systems.stateSystem,
        self.__systems.turnSystem,
        self.__systems.damageOverTimeSystem,
        self.__systems.markSystem,
        self.__systems.collisionSystem
    )

    self.moveSystem = self.ecs:getSystem(self.__systems.moveSystem)
    self.animationSystem = self.ecs:getSystem(self.__systems.animationSystem)
    self.stateSystem = self.ecs:getSystem(self.__systems.stateSystem)
    self.crowdControlSystem = self.ecs:getSystem(self.__systems.crowdControlSystem)
    self.renderSystem = self.ecs:getSystem(self.__systems.renderSystem)
    self.itemSystem = self.ecs:getSystem(self.__systems.itemSystem)
    self.statsSystem = self.ecs:getSystem(self.__systems.statsSystem)
    self.combatSystem = self.ecs:getSystem(self.__systems.combatSystem)
    self.timerSystem = self.ecs:getSystem(self.__systems.timerSystem)
    self.buffDebuffSystem = self.ecs:getSystem(self.__systems.buffDebuffSystem)
    self.turnSystem = self.ecs:getSystem(self.__systems.turnSystem)
    self.statusEffectSystem = self.ecs:getSystem(self.__systems.statusEffectSystem)
    self.stateSystem = self.ecs:getSystem(self.__systems.stateSystem)
    self.damageOverTimeSystem = self.ecs:getSystem(self.__systems.damageOverTimeSystem)
    self.markSystem = self.ecs:getSystem(self.__systems.markSystem)
    self.collisionSystem = self.ecs:getSystem(self.__systems.collisionSystem)
end

function MatchManager:generateTerrain(node_type)
    self.matchNode = node_type
    self.board = matchTerrain[self.matchNode.place][self.matchNode.variant](self.width, self.height)
end

-- ditch these and just use the entity factory directly
function MatchManager:newAnimal(species, x, y, level)
    assert(animalData[species], "Species does not exist!")
    return EntityFactory:createAnimal(species,x , y, level)
end

function MatchManager:newObject(name, x, y)
    self.ecs:addEntity(EntityFactory:createObject(name,x , y))
end

function MatchManager:newFlower(name, x, y)
    self.ecs:addEntity(EntityFactory:createFlower(name, x , y))
end

function MatchManager:newMark(name, x, y)
    self.ecs:addEntity(EntityFactory:createMark(name, x, y))
end

function MatchManager:newProjectile(type, x, y, targetX, targetY, ownerId)
    self.ecs:addEntity(EntityFactory:createProjectile(type, x, y, targetX, targetY, ownerId))
end

function MatchManager:getEntityById(id)
    for _, entity in ipairs(self.ecs:getEntities()) do
        if entity.metadata.id == id then
            return entity
        end
    end
    return nil
end

function MatchManager:draw()

    love.graphics.setShader(noiseShader)

    for i = 1, self.height do
        for j = 1, self.width do

            if  j - 1 == SceneManager.currentScene.inputManager.hoveredTileX and
                i - 1 == SceneManager.currentScene.inputManager.hoveredTileY then
                    love.graphics.setShader(shimmerShader)
            else
                love.graphics.setShader(noiseShader)

            end

            love.graphics.setColor(1 ,1 ,1 ,1)
            love.graphics.draw(
                RM.image, 
                self.board.terrain[i][j].quad, 
                (j - 1) * RM.tileSize, 
                (i - 1) * RM.tileSize, 
                0, 
                RM.increaseFactor,
                RM.increaseFactor
            )
        end
    end

    love.graphics.setShader()

    self.ecs:emit("draw")
    self.states:draw()
end


function MatchManager:addToTeam(teamId, animal)
    -- if animal:getWorld() then
    --     animal:getWorld():removeEntity(animal)
    -- end

    self.teamManager:addToTeam(teamId, animal)
    self.ecs:addEntity(animal)
    -- do this somewhere else
    -- self.ecs:emits('update', 0)
    self.ecs:__flush()
    self.statsSystem:initializeStats()
end


function MatchManager:isSteppable(x, y, entity)

    if x >= 0 and x < self.width and y >= 0 and y < self.height then

        if entity then
            local terrainCheck = false
            local terrainTile = self.board.terrain[y + 1][x + 1]
    
            for i, tile in ipairs(entity.position.stepsOn) do
                if tile == terrainTile.type then
                    terrainCheck = true
                end
            end
    
            if not terrainCheck then return false end
        end

        local entities = self.moveSystem:findByCoordinates(x, y)

        for i, e in ipairs(entities) do
            if e == entity then
                goto continue
            end

            if not e.position.isSteppable then
                return false
            end

            ::continue::
        end
        
        return true
    end

    return false
end


function MatchManager:getSpawnPositions(side)
    if side then
        assert(side == "top" or side == "bottom", "Invalid argument, expected 'top' or 'bottom', instead got - " .. side)
    end

    local positions = {}

    local heightTop, heightBottom

    if side == "top" then
        heightTop = 0
        heightBottom = math.floor(self.height / 2) - 1
    elseif side == "bottom" then
        heightTop = math.floor(self.height / 2)
        heightBottom = self.height - 1
    elseif side == nil then
        heightTop = 0
        heightBottom = self.height - 1
    end

    for i = heightTop, heightBottom do
        for j = 0, self.width - 1 do
            if #self.moveSystem:findByCoordinates(j, i) == 0 then
                table.insert(positions, {j, i})
            end
        end
    end

    return positions
end


function MatchManager:getEmptyTiles()

    local positions = {}

    for i = 0, self.height do
        for j = 0, self.width - 1 do
            if self:isSteppable(j, i) then
                table.insert(positions, {j, i})
            end
        end
    end

    return positions

end


function MatchManager:generateEnemies()
    local positions = self:getSpawnPositions("top")

    local species = {}

    -- -1 to acount for start node
    local amountMin = stageMobAmount[gs.run.currentStage][self.matchNode.x - 1][1]
    local amountMax = stageMobAmount[gs.run.currentStage][self.matchNode.x - 1][2]

    local amount = amountMin + math.ceil(math.random() * (amountMax - amountMin))
    
    pickLimited(matchMobRates[self.matchNode.place][self.matchNode.variant], amount, species)

    local enemies = {}

    for _, value in ipairs(species) do
        local pos = math.random(#positions)
        local level = 1

        if math.random() < stageMobLevels[gs.run.currentStage][self.matchNode.x - 1].negativeChance then
            level = -1
        end
        
        if math.random() < stageMobLevels[gs.run.currentStage][self.matchNode.x - 1].levelUpChance then                
            local min = stageMobLevels[gs.run.currentStage][self.matchNode.x - 1].minLevel
            local max = stageMobLevels[gs.run.currentStage][self.matchNode.x - 1].maxLevel

            level = min + math.random(max-min) - 1
        end

        if value == self.matchNode.place then
            level = self.matchNode.level
        end

        local animal = self:newAnimal(value, positions[pos][1], positions[pos][2], level)

        local chance = stageMobItems[gs.run.currentStage][self.matchNode.x - 1].chance
        
        if math.random() < chance then
            local min = stageMobItems[gs.run.currentStage][self.matchNode.x - 1].min
            local max = stageMobItems[gs.run.currentStage][self.matchNode.x - 1].max
            local itemAmount = min + math.random(max-min)
            local items = getRandomItems(gs.run.currentStage, itemAmount)

            for _, item in ipairs(items) do
                print("giving item" .. item)
                self.itemSystem:giveItem(animal, item)
            end
        end

        -- local items = {}

        -- if self.matchNode.x < math.random(10) then
        --     self.itemSystem:giveItem(animal, getRandomItems(1, 1)[1])
        -- end

        table.remove(positions, pos)
        self:addToTeam(2, animal)
    end

    -- self.ecs:emit('update', 0.01)
    self.ecs:__flush()

    return enemies
end


function MatchManager:generateFlowers()
    if flowerData[self.matchNode.place] then
        
        local data = flowerData[self.matchNode.place]

        local amountMin = data.amount[1]
        local amountMax = data.amount[2]

        local positions = self:getSpawnPositions()

        local species = {}
    
        local amount = amountMin + math.ceil(math.random() * (amountMax - amountMin))
    
        pickLimited(data.rates, amount, species)

        for _, value in ipairs(species) do
            local pos = math.random(#positions)
            self:newFlower(value, positions[pos][1], positions[pos][2])
            table.remove(positions, pos)
        end
    
        -- self.ecs:emit('update', 0.01)
        self.ecs:__flush()

    end
end


function MatchManager:poissonDisk()

    local roomWidth, roomHeight = self.width, self.height
    local minDist = 2
    local attempts = 30

    local points = {} -- Final list
    local activeList = {} -- List of points currently generating neighbors

    local function distSquared(x1, y1, x2, y2)
        return (x1 - x2)^2 + (y1 - y2)^2
    end

    local function isPointValid(x, y)
        for _, point in ipairs(points) do
            local px, py = point[1], point[2]
            if distSquared(x, y, px, py) < minDist^2 
            or #self.moveSystem:findByCoordinates(x, y) > 0 then
                return false
            end
        end
        return true
    end

    local function generateRandomPoint(x, y)
        local angle = math.random() * 2 * math.pi
        local radius = math.random() * minDist + minDist
        local newX = math.floor(x + math.cos(angle) * radius + 0.5)
        local newY = math.floor(y + math.sin(angle) * radius + 0.5)
        return newX, newY
    end

    local function addPoint(x, y)
        if x >= 0 and x < roomWidth and y >= 0 and y < roomHeight and isPointValid(x, y) then
            table.insert(points, {x, y})
            table.insert(activeList, {x, y})
        end
    end

    local startX, startY = math.random(0, roomWidth - 1), math.random(0, roomHeight - 1)
    addPoint(startX, startY)

    while #activeList > 0 do
        minDist = 1 + math.floor(math.random(2))
        local activeIndex = math.random(#activeList)
        local activePoint = table.remove(activeList, activeIndex)
        local x, y = activePoint[1], activePoint[2]

        for _ = 1, attempts do
            local newX, newY = generateRandomPoint(x, y)
            addPoint(newX, newY)
        end
    end

    return points
end


function MatchManager:generateObjects()
    local poissonSamples = self:poissonDisk()   

    local objectNames = {}

    pickLimited(matchObjectRates[self.matchNode.place][self.matchNode.variant], stageObjectAmount[1][1] + math.random(stageObjectAmount[1][2] - stageObjectAmount[1][1]), objectNames)

    for _, name in ipairs(objectNames) do
        if #poissonSamples > 0 then
            local pos = math.random(#poissonSamples)
            self:newObject(name, poissonSamples[pos][1], poissonSamples[pos][2])
            table.remove(poissonSamples, pos)
        end
    end

    -- self.ecs:emit('update', 0.01)
    self.ecs:__flush()
end

function MatchManager:generateMarks()
    local poissonSamples = self:poissonDisk()   

    local markNames = {}
    
    if matchMarkRates[self.matchNode.place] and matchMarkRates[self.matchNode.place][self.matchNode.variant] then
        pickLimited(matchMarkRates[self.matchNode.place][self.matchNode.variant], 2, markNames)
    else
        return
    end
    
    for _, name in ipairs(markNames) do
        if #poissonSamples > 0 then
            local pos = math.random(#poissonSamples)
            self:newMark(name, poissonSamples[pos][1], poissonSamples[pos][2])
            table.remove(poissonSamples, pos)
        end
    end
end

function MatchManager:hasMovesLeft(entity)
    return self.stateSystem:hasMovesLeft(entity)
end

function MatchManager:areAllMobsIdle()
    if self.animationSystem:allAnimationsDone() and
       self.moveSystem:allMovesDone() and
       self.timerSystem:allTimersDone() then
        return true
    end
    return false
end


function MatchManager:checkForWinner()
    local aliveTeams = {}
    
    for teamId, team in ipairs(self.teamManager.teams) do
        local teamAlive = false
        for _, member in ipairs(team.members) do
            if member.state.current ~= "dead" then
                teamAlive = true
                break
            end
        end

        if teamAlive then
            table.insert(aliveTeams, teamId)
        end
    end

    if #aliveTeams == 1 then
        self.winnerId = aliveTeams[1]
        self.states:set_state("result")
    end
end


function MatchManager:removeEntitiesFromTheWorld()
    for _, entity in ipairs(self.ecs:getEntities()) do
        self.ecs:removeEntity(entity)
        print("removing: " .. entity.metadata.type, (entity.metadata.species or ""))
        -- entity.__world = nil
        -- entity = nil
    end
    self.ecs:__flush()
    -- self.ecs:emit("update", 0.01)
end


function MatchManager:preparePlayer()
    for _, animal in ipairs(self.teamManager.teams[1].members) do
        animal.stats.current.hp = animal.stats.current.maxHp
        animal.state.currentTurnMoves = 0
        self.animationSystem:removeAll(animal)
        self.moveSystem:removeAll(animal)
        self.damageOverTimeSystem:removeAll(animal)
        self.buffDebuffSystem:removeAll(animal)
        self.collisionSystem:removeAll(animal)
        self.statusEffectSystem:removeAll(animal)
        self.stateSystem:changeState(animal, "idle")
    end
end


function MatchManager:positionPlayer()
    local positions = self:getSpawnPositions('bottom')

    local pos = positions[math.ceil(math.random() * #positions)]
    self.moveSystem:setPosition(self.teamManager.teams[1].members[1], pos[1], pos[2])
    -- self.ecs:emit('update', 0.01)
    self.ecs:__flush()
end


function MatchManager:onExit()
    -- not happy with this approach. we should just create MatchManager and register events once
    self.eventManager:reset()
    -- self:removeEntitiesFromTheWorld()
    -- self.ecs = nil
    -- gs.match = nil
end


function MatchManager:update(dt)
    self.ecs:emit("update", dt)
    self.teamManager:update(dt)
    self.states:update(dt)
    self:checkForWinner()

    shimmerShader:send('time', love.timer.getTime())
    noiseShader:send("time", love.timer.getTime())
end

function MatchManager:initSystems()
    self.__systems = {
        stateSystem = "stateSystem",
        moveSystem = "moveSystem",
        combatSystem = "combatSystem",
        timerSystem = "timerSystem",
        tagSystem = "tagSystem",
        itemSystem = "itemSystem",
        buffsDebuffSystem = "buffDebuffSystem",
        renderSystem = "renderSystem",
        statusEffectSystem = "statusEffectSystem",
        animationSystem = "animationSystem",
        crowdControlSystem = "crowdControlSystem",
        damageOverTimeSystem = "damageOverTimeSystem"
    }

    self.stateSystem = self.ecs:getSystem(self.__systems.stateSystem)
    self.moveSystem = self.ecs:getSystem(self.__systems.moveSystem)
    self.combatSystem = self.ecs:getSystem(self.__systems.combatSystem)
    self.timerSystem = self.ecs:getSystem(self.__systems.timerSystem)
    self.tagSystem = self.ecs:getSystem(self.__systems.tagSystem)
    self.itemSystem = self.ecs:getSystem(self.__systems.itemSystem)
    self.buffsDebuffSystem = self.ecs:getSystem(self.__systems.buffsDebuffSystem)
    self.renderSystem = self.ecs:getSystem(self.__systems.renderSystem)
    self.statusEffectSystem = self.ecs:getSystem(self.__systems.statusEffectSystem)
    self.animationSystem = self.ecs:getSystem(self.__systems.animationSystem)
    self.crowdControlSystem = self.ecs:getSystem(self.__systems.crowdControlSystem)
    self.damageOverTimeSystem = self.ecs:getSystem(self.__systems.damageOverTimeSystem)
    
    gs.damageOverTimeSystem = self.damageOverTimeSystem
end

return MatchManager