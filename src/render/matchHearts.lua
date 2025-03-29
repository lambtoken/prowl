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
        animationSpeed = 1.5, -- How fast the hearts move
        animationAmplitude = 2, -- How far the hearts move
        waveSpeed = 0.8, -- How fast the wave moves
        waveLength = 0.5, -- How long each wave is
        spacing = 0, -- Current spacing between hearts
        targetSpacing = 0, -- Target spacing when taking damage
        spacingSpeed = 3, -- How fast the spacing changes
        shakeAmount = 8, -- How much to shake when taking damage
        shakeDuration = 1, -- How long to shake
        shakeTimer = 0, -- Current shake timer
        isShaking = false, -- Whether currently shaking
        scaleAmount = 1.2, -- How much to scale up when hit
        currentScale = 1, -- Current scale of hearts
        scaleSpeed = 4, -- How fast the scale changes
    }
    setmetatable(o, self)
    o.__index = self

    -- Listen for damage events
    local heartsObj = o -- Capture the hearts object in the closure
    EventManager:on("damageBubble", function(entity, amount)
        -- Check if the damaged entity is in team 1 (player's team)
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
    -- Start shaking animation
    self.isShaking = true
    self.shakeTimer = self.shakeDuration
    self.currentScale = self.scaleAmount
    
    -- Update target spacing based on new HP
    local maxHp = self.player.stats.current.maxHp
    local currentHp = self.player.stats.current.hp
    self.targetSpacing = (maxHp - currentHp) * 2
end

function hearts:update(dt)
    self.animationTime = self.animationTime + dt * self.animationSpeed
    
    -- Update shake animation
    if self.isShaking then
        self.shakeTimer = self.shakeTimer - dt
        if self.shakeTimer <= 0 then
            self.isShaking = false
            self.currentScale = 1
        end
    end
    
    -- Update scale animation
    if self.currentScale > 1 then
        self.currentScale = math.max(1, self.currentScale - dt * self.scaleSpeed)
    end
    
    -- Update spacing based on damage
    local maxHp = self.player.stats.current.maxHp
    local currentHp = self.player.stats.current.hp
    self.targetSpacing = (maxHp - currentHp) * 2 -- More spacing when more damage taken
    
    -- Smoothly interpolate current spacing to target spacing
    if self.spacing < self.targetSpacing then
        self.spacing = math.min(self.spacing + dt * self.spacingSpeed, self.targetSpacing)
    elseif self.spacing > self.targetSpacing then
        self.spacing = math.max(self.spacing - dt * self.spacingSpeed, self.targetSpacing)
    end
end

function hearts:draw()
    local quad = love.graphics.newQuad(spriteTable["heart_empty"][1] * RM.spriteSize, spriteTable["heart_empty"][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
    
    -- Calculate shake offset with easing
    local shakeOffset = 0
    if self.isShaking then
        local shakeProgress = self.shakeTimer / self.shakeDuration
        -- Use a quadratic easing function for more dramatic shake
        shakeOffset = math.sin(self.shakeTimer * 20) * self.shakeAmount * (shakeProgress * shakeProgress)
    end
    
    -- Draw empty hearts with wave effect
    for i = 1, self.player.stats.current.maxHp do
        -- Calculate individual heart position with wave effect
        local waveOffset = math.sin(self.animationTime * self.waveSpeed + i * self.waveLength) * self.animationAmplitude
        local xPos = math.floor((i - 1) * (RM.tileSize - 10 + self.spacing))
        love.graphics.draw(RM.image, quad, xPos + shakeOffset, waveOffset * RM.increaseFactor, 0, RM.increaseFactor * self.currentScale)
    end

    quad = love.graphics.newQuad(spriteTable["heart"][1] * RM.spriteSize, spriteTable["heart"][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)

    -- Draw filled hearts with wave effect
    for i = 1, self.player.stats.current.hp do
        -- Calculate individual heart position with wave effect
        local waveOffset = math.sin(self.animationTime * self.waveSpeed + i * self.waveLength) * self.animationAmplitude
        local xPos = math.floor((i - 1) * (RM.tileSize - 10 + self.spacing))
        love.graphics.draw(RM.image, quad, xPos + shakeOffset, waveOffset * RM.increaseFactor, 0, RM.increaseFactor * self.currentScale)
    end
end

return hearts