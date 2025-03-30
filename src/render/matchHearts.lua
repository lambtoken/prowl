local RM = require ('src.render.RenderManager'):getInstance()
local spriteTable = require 'src.render.spriteTable'
local EventManager = require("src.state.events"):getInstance()
local gs = require("src.state.GameState"):getInstance()

local hearts = {}
hearts.__index = hearts

function hearts:new(playerRef)
    local o = {
        player = playerRef,
        animationTime = 0,
        animationSpeed = 1.5, 
        animationAmplitude = 2, 
        waveSpeed = 0.8, 
        waveLength = 0.5, 
        spacing = 0, 
        targetSpacing = 0, 
        spacingSpeed = 3, 
        shakeAmount = 8, 
        shakeDuration = 1, 
        shakeTimer = 0,
        isShaking = false, 
        scaleAmount = 1.2,
        currentScale = 1,
        scaleSpeed = 4, 
    }
    setmetatable(o, self)
    o.__index = self

    local heartsObj = o 
    EventManager:on("damageBubble", function(entity, amount)
        if gs.currentMatch and gs.currentMatch.teamManager and gs.currentMatch.teamManager.teams[1] then
            for _, teamMember in ipairs(gs.currentMatch.teamManager.teams[1].members) do
                if entity == teamMember then
                    heartsObj:onDamage(amount)
                    break
                end
            end
        end
    end)

    return o
end

function hearts:onDamage(amount)
    self.isShaking = true
    self.shakeTimer = self.shakeDuration
    self.currentScale = self.scaleAmount
    
    local maxHp = self.player.stats.current.maxHp
    local currentHp = self.player.stats.current.hp
    self.targetSpacing = (maxHp - currentHp) * 2
end

function hearts:update(dt)
    self.animationTime = self.animationTime + dt * self.animationSpeed
    
    if self.isShaking then
        self.shakeTimer = self.shakeTimer - dt
        if self.shakeTimer <= 0 then
            self.isShaking = false
            self.currentScale = 1
        end
    end
    
    if self.currentScale > 1 then
        self.currentScale = math.max(1, self.currentScale - dt * self.scaleSpeed)
    end
    
    local maxHp = self.player.stats.current.maxHp
    local currentHp = self.player.stats.current.hp
    self.targetSpacing = (maxHp - currentHp) * 2 
    
    if self.spacing < self.targetSpacing then
        self.spacing = math.min(self.spacing + dt * self.spacingSpeed, self.targetSpacing)
    elseif self.spacing > self.targetSpacing then
        self.spacing = math.max(self.spacing - dt * self.spacingSpeed, self.targetSpacing)
    end
end

function hearts:draw()
    local quad = love.graphics.newQuad(spriteTable["heart_empty"][1] * RM.spriteSize, spriteTable["heart_empty"][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
    
    local shakeOffset = 0
    if self.isShaking then
        local shakeProgress = self.shakeTimer / self.shakeDuration
        shakeOffset = math.sin(self.shakeTimer * 20) * self.shakeAmount * (shakeProgress * shakeProgress)
    end
    
    for i = 1, self.player.stats.current.maxHp do
        local waveOffset = math.sin(self.animationTime * self.waveSpeed + i * self.waveLength) * self.animationAmplitude
        local xPos = math.floor((i - 1) * (RM.tileSize - 10 + self.spacing))
        love.graphics.draw(RM.image, quad, xPos + shakeOffset, waveOffset * RM.increaseFactor, 0, RM.increaseFactor * self.currentScale)
    end

    quad = love.graphics.newQuad(spriteTable["heart"][1] * RM.spriteSize, spriteTable["heart"][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)

    for i = 1, self.player.stats.current.hp do
        local waveOffset = math.sin(self.animationTime * self.waveSpeed + i * self.waveLength) * self.animationAmplitude
        local xPos = math.floor((i - 1) * (RM.tileSize - 10 + self.spacing))
        love.graphics.draw(RM.image, quad, xPos + shakeOffset, waveOffset * RM.increaseFactor, 0, RM.increaseFactor * self.currentScale)
    end
end

return hearts