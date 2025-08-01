local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local RM = require ('src.render.RenderManager'):getInstance()
local Camera = require 'libs.hump_camera'
local button = require 'src.render.ui.button'
local turnTracker = require 'src.render.ui.match.turnTracker'
local InputManager = require 'src.run.InputManager'
local HangingPiece = require 'src.render.ui.match.HangingPiece'
local Pattern = require "src.render.ui.match.Pattern"
local TextBubbleManager = require "src.render.ui.match.TextBubbleManager"
local ParticleSystem = require "src.render.ParticleManager"
local gray_shader = require "src.render.shaders.gray_shader"
local gs = require("src.state.GameState"):getInstance()
local Hearts = require "src.render.matchHearts"
local animalStats = require "src.render.animalStats"
local dangerZone = require "src.render.match.dangerZone"
local pretty = require "libs.batteries.pretty"
local slidingText = require "src.render.slidingText"
local newEntityTooltip = require "src.render.components.entity_tooltip"
local mold = require "libs.mold"
local mouse = require "src.input.mouse"

local match = Scene:new('match')

function match:enter()
    self.root = mold.Container:new():setRoot(RM.windowWidth, RM.windowHeight)
        :setAlignContent("center")
        :setJustifyContent("center")
    self.root:resize()
    
    self.match = gs.match
    self.match:init()
    self.match:generateTerrain(gs.currentMatchNode)
    self.camera = Camera((self.match.width * RM.tileSize) / 2, (self.match.height * RM.tileSize) / 2)
    self.matchEvents = self.match.eventManager

    self.match.teamManager:newTeam("player")
    self.match.teamManager:newTeam("bot")

    -- ugly check for now. will refactor.
    if(self.match.teamManager.teams[1].members[1] == nil) then
        self.match:addToTeam(1, gs.run.team[1])
        --self.match:addToTeam(1, self.match:newAnimal("bear", 4, 4, 1))
    end

    -- self.match.itemSystem:giveItem(gs.run.team[1], "gear")

    self.turnTracker = turnTracker:new()
    self.turnTracker:load(self.match.teamManager)

    self.hangingPiece = HangingPiece:new()
    self.hangingPiece:load()

    self.animalStats = animalStats:new()

    self.inputManager = InputManager:new(self.camera, self.match)
    self.inputManager:setHangingPiece(self.hangingPiece)

    self.pattern = Pattern:new(self.inputManager)
    self.inputManager:setPatternDisplay(self.pattern)
    
    -- self.inputManager.match.animalStats = self.animalStats

    self.endTurnButton = button(
        "rest", 
        function() 
            self.match.teamManager.teams[self.match.teamManager.turnTeamId].rest = false
            self.match.teamManager.states:set_state("end_phase")
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
    self.matchEvents:on("createParticle", function(type, x, y, arg1, mode)
        self.particleSystem:play(type, x, y, arg1, mode)
    end)

    self.paused = false
    self.grayShader = love.graphics.newShader(gray_shader)

    self.match:generateObjects()
    self.match:generateEnemies()
    self.match:generateFlowers()
    -- self.match:generateMarks()

    self.match:preparePlayer()
    self.match:positionPlayer()

    self.hearts = Hearts:new(gs.run.team[1])

    self.match.teamManager.states:set_state("start_phase")
    -- self.ddd = self.match.ecs:serialize()

    -- hook up sliding text to matchmanager events
    self.slidingText = slidingText:new()

    self.tooltip = nil

    self.resultText = nil
    self.resultTextSize = 100

    self.match.eventManager:on("standByPhase", function(teamId)
        self.slidingText:slide("Stand By", RM.teamColors[teamId])
    end)
    self.match.eventManager:on("endPhase", function(teamId)
        self.slidingText:slide("End Turn", RM.teamColors[teamId])
    end)
    self.match.eventManager:on("mainPhase", function(teamId)
        self.slidingText:slide("Main Phase", RM.teamColors[teamId])
    end)
end

function match:displayResult(message)
    self.resultText = message
end

function match:update(dt) 
    if self.paused then
        return
    end

    -- this should be moved to button and only run when entered
    if self.match.teamManager.turnTeamId == 1 then
        if self.match.teamManager:canCurrentTeamRest() and self.match:areAllMobsIdle() and self.match.stateSystem:teamHasMovesLeft(1) then
            self.endTurnButton.disabled = false
        else
            self.endTurnButton.disabled = true
        end
        self.endTurnButton:update(dt)
    end

    self.match:update(dt)
    self.inputManager:update(dt)
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

    self.slidingText:update(dt)
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
    
    if self.tooltip then
        self.tooltip.anchorX = x
        self.tooltip.anchorY = y
    end
end

function match:mousepressed(x, y, btn) 
    if not self.paused then
        
        if self.match.teamManager.turnTeamId == 1 and self.endTurnButton:mousepressed(x, y, btn)then
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
        if self.match.teamManager.turnTeamId == 1 then
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
    
    self.camera:attach(0, 0, RM.windowWidth, RM.windowHeight, true)
    self.match:draw()
    -- dangerZone(self.match.teamManager.moveQueue, self.inputManager.hoveredTileX, self.inputManager.hoveredTileY)
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
        -- local wx, wy = self.camera:cameraCoords(0, 0)
        -- love.graphics.intersectScissor(wx, wy, self.match.width * RM.tileSize, self.match.height * RM.tileSize)
        RM:pushShader("shimmer")
        RM:sendUniform("time", love.timer.getTime())
        RM:sendUniform("frequency", 20.0)
        self.pattern:drawMovePattern()
        self.pattern:drawAttackPattern()
        RM:popShader()
        -- love.graphics.setScissor()
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
    
    if self.match.teamManager.turnTeamId == 1 then
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
    
    self.slidingText:draw()
    
    self.root:draw()
    
    if self.resultText then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(getFont('basis33', self.resultTextSize))
        love.graphics.print(self.resultText, RM.windowWidth / 2 - getFont('basis33', self.resultTextSize):getWidth(self.resultText) / 2, RM.windowHeight / 2 - getFont('basis33', self.resultTextSize):getHeight(self.resultText) / 2)
    end
end


function match:exit() 
    self.match:onExit()
    self.match = nil
end

function match:keypressed(key)
    if key == 'escape' then
        self.paused = not self.paused
    end
end

function match:createTooltip(entity)
    self.tooltip = newEntityTooltip(entity)
    
    -- Set tooltip position to current mouse position
    self.tooltip.anchorX = mouse.x
    self.tooltip.anchorY = mouse.y
    
    self.root:addChild(self.tooltip)
    self.root:resize()
end

function match:removeTooltip()
    if self.tooltip then
        self.root:removeChild(self.tooltip)
        self.tooltip = nil
    end
    self.root:resize()
end

return match