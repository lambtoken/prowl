local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local RM = require ('src.render.RenderManager'):getInstance()
local MatchManager = require 'src.run.MatchManager'
local sceneM = require('src.scene.SceneManager'):getInstance()
local Camera = require 'libs.hump_camera'
local button = require 'src.render.ui.button'
local turnTracker = require 'src.render.ui.match.turnTracker'
local mouse = require 'src.input.mouse'
local InputManager = require 'src.run.InputManager'
local HangingPiece = require 'src.render.ui.match.HangingPiece'
local EventManager = require("src.state.events"):getInstance()
local Pattern = require "src.render.ui.match.Pattern"
local TextBubbleManager = require "src.render.ui.match.TextBubbleManager"
local ParticleSystem = require "src.render.ParticleManager"
local gray_shader = require "src.render.shaders.gray_shader"
local gs = require("src.state.GameState"):getInstance()
local Hearts = require "src.render.matchHearts"
local animalStats = require "src.render.animalStats"

local match = Scene:new('match')

function match:enter()
    gs.currentMatch = MatchManager:new(gs.currentMatchNode)
    self.currentMatch = gs.currentMatch
    self.currentMatch:generateTerrain()
    self.camera = Camera((self.currentMatch.width * RM.tileSize) / 2, (self.currentMatch.height * RM.tileSize) / 2)
    self.matchEvents = self.currentMatch.eventManager

    self.currentMatch.teamManager:newTeam("player")
    self.currentMatch.teamManager:newTeam("bot")

    -- ugly check for now. will refactor.
    if(self.currentMatch.teamManager.teams[1].members[1] == nil) then
        self.currentMatch:addToTeam(1, gs.run.team[1])
        --self.currentMatch:addToTeam(1, self.currentMatch:newAnimal("bear", 4, 4, 1))
    end

    self.currentMatch.itemSystem:giveItem(gs.run.team[1], "stappler")
    self.currentMatch.itemSystem:giveItem(gs.run.team[1], "poison_dart")

    self.currentMatch:preparePlayer()
    self.currentMatch:positionPlayer()

    self.turnTracker = turnTracker:new()
    self.turnTracker:load(self.currentMatch.teamManager)

    self.hangingPiece = HangingPiece:new()
    self.hangingPiece:load()

    self.animalStats = animalStats:new()

    self.inputManager = InputManager:new(self.camera, self.currentMatch)
    self.inputManager:setHangingPiece(self.hangingPiece)

    self.pattern = Pattern:new(self.inputManager)
    self.inputManager:setPatternDisplay(self.pattern)
    
    -- self.inputManager.currentMatch.animalStats = self.animalStats

    self.endTurnButton = button(
        "rest", 
        function() 
            self.currentMatch.teamManager.teams[self.currentMatch.teamManager.turnTeamId].rest = false
            self.currentMatch.teamManager.states:set_state("end_phase")
        end
    )

    self.endTurnButton.width = 200
    self.endTurnButton.height = 50
    self.endTurnButton.fontSize = 30
    self.endTurnButton.screenX = RM.windowWidth - 230
    self.endTurnButton.screenY = RM.windowHeight - 80
    self.endTurnButton:load()

    self.TextBubbleManager = TextBubbleManager:new()
    self.matchEvents:on("damageBubble", function(entity, amount, crit) self.TextBubbleManager:newBubble("damage", entity, amount, crit) end)
    self.matchEvents:on("shortCCBubble", function(entity, ccType) self.TextBubbleManager:newBubble("shortCC", entity, ccType) end)
    self.matchEvents:on("statusEffectBubble", function(entity, effectName) self.TextBubbleManager:newBubble("statusEffect", entity, effectName) end)
    self.matchEvents:on("removeStatusEffect", function(entity, effectName) self.TextBubbleManager:endStatusEffect(entity, effectName) end)
    self.matchEvents:on("killEntityBubbles", function(entity) self.TextBubbleManager:killEntityBubbles(entity) end)

    self.isShaking = false
    self.shakeTime = 0.3
    self.shakeTimer = self.shakeTime
    self.shakeOffsetX = 0
    self.shakeOffsetY = 0
    self.shakeMagnitude = 3
    self.matchEvents:on("screenShake", function() self.isShaking = true end)

    self.particleSystem = ParticleSystem:new()
    self.matchEvents:on("createParticle", function(type, x, y, arg1)
        self.particleSystem:play(type, x, y, arg1)
    end)

    self.paused = false
    self.grayShader = love.graphics.newShader(gray_shader)

    self.currentMatch:generateObjects()
    self.currentMatch:generateEnemies()
    self.currentMatch:generateFlowers()
    self.currentMatch:generateMarks()

    self.hearts = Hearts:new(gs.run.team[1])

    

    -- self.currentMatch:newObject('vase', 5, 5)
    -- self.currentMatch:newFlower('red_flower', 5, 6)
    -- self.currentMatch:newFlower('red_flower', 2, 6)
    -- self.currentMatch:newFlower('red_flower', 5, 4)
    -- self.currentMatch:newFlower('red_flower', 7, 4)
end

function match:update(dt) 
    if not self.paused then
        if self.currentMatch.teamManager.turnTeamId == 1 then
            if self.currentMatch.teamManager:canCurrentTeamRest() and self.currentMatch:areAllMobsIdle() and self.currentMatch.stateSystem:hasMovesLeft(self.currentMatch.teamManager.teams[1].members[1]) then
                self.endTurnButton.disabled = false
            else
                self.endTurnButton.disabled = true
            end
            self.endTurnButton:update(dt)
        end

        self.currentMatch:update(dt)
        self.hangingPiece:update(dt)
        self.turnTracker:update(dt)
        self.TextBubbleManager:update(dt)
        self.particleSystem:update(dt)
        self.hearts:update(dt)
        
        if self.isShaking then    
            self.shakeTimer = self.shakeTimer - dt
    
            if self.shakeTimer > 0 then
                self.shakeOffsetX = (math.random(-self.shakeMagnitude, self.shakeMagnitude))
                self.shakeOffsetY = (math.random(-self.shakeMagnitude, self.shakeMagnitude))
    
            else
                self.isShaking = false
                self.shakeTimer = self.shakeTime
                self.shakeOffsetX = 0
                self.shakeOffsetY = 0
            end
        end
    end
end 

function match:mousemoved(x, y)
    if not self.paused then
        self.inputManager:mousemoved(x, y)
    end

    if self.turnTracker:mousemoved(x, y) then
        self.teamOutline = true
    else
        self.teamOutline = false
    end
end

function match:mousepressed(x, y, btn) 
    if not self.paused then
        
        if self.currentMatch.teamManager.turnTeamId == 1 and self.endTurnButton:mousepressed(x, y, btn)then
            return
        end

        if self.turnTracker:mousepressed(x, y, btn) then
            return
        end
        self.inputManager:mousepressed(x, y, btn)
    end
end

function match:mousereleased(x, y, btn)
    if not self.paused then
        if self.currentMatch.teamManager.turnTeamId == 1 then
            if self.endTurnButton:mousereleased(x, y, btn) then
            end
        end
            
    self.inputManager:mousereleased(x, y, btn)
    end
end

function match:draw()

    if self.paused then
        love.graphics.setShader(self.grayShader)
    else
        love.graphics.setShader(nil)
    end
    
    love.graphics.push()
    love.graphics.translate(self.shakeOffsetX, self.shakeOffsetY)

    if self.inputManager.selectedAnimal then
        self.pattern:preparePatterns()
    end

    self.camera:attach()
    self.currentMatch:draw()
    self.particleSystem:draw()
    self.TextBubbleManager:draw()
    
    -- local x, y = self.camera:worldCoords(mouse.x, mouse.y)

    -- love.graphics.setColor(0.6, 0.6, 0.6, 1)
    -- love.graphics.rectangle(
    --     'line', 
    --     (x / RM.tileSize) * RM.tileSize - 
    --     (x / RM.tileSize) * RM.tileSize % RM.tileSize, 
    --     (y / RM.tileSize) * RM.tileSize - 
    --     (y / RM.tileSize) * RM.tileSize % RM.tileSize, 
    --     RM.tileSize, 
    --     RM.tileSize
    -- )

    love.graphics.setColor(1, 1, 1, 1)

    if self.inputManager.selectedAnimal then
        self.pattern:drawMovePattern()
        self.pattern:drawAttackPattern()
    end
    
    self.camera:detach()
    
    love.graphics.pop()
    
    if self.inputManager.selectedAnimal then
        self.hangingPiece:draw()
    end
    
    self.hearts:draw()

    if self.animalStats.animalRef and self.animalStats.animalRef.state.current ~= "dead" then
        self.animalStats:draw()
    end
    
    
    self.turnTracker:draw()

    if self.currentMatch.teamManager.turnTeamId == 1 then
        self.endTurnButton:draw()
    end

    if self.paused then
        local pausedFont = getFont('basis33', 50)
    
        love.graphics.setShader(nil)
        love.graphics.setFont(pausedFont)
        love.graphics.print(
            "paused",
            RM.windowWidth / 2 - pausedFont:getWidth("paused") / 2,
            RM.windowHeight / 2 - pausedFont:getHeight() / 2
        )
    end

end

function match:exit() 
    self.currentMatch:onExit()
    self.currentMatch = nil
end

function match:keypressed(key)
    if key == 'escape' then
        -- sceneM:switchScene('runMap')
        self.paused = not self.paused
    end

    if key == 'a' then
        self.currentMatch.winnerId = 1
        self.currentMatch.states:set_state("result")
    end

    if key == 's' then
        self.currentMatch.winnerId = 2
        self.currentMatch.states:set_state("result")
    end
end

return match