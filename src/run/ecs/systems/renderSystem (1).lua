local Concord = require("libs.concord")
local RM = require ('src.render.RenderManager'):getInstance()
local sceneManager = require("src.scene.SceneManager"):getInstance()
local outline_shader = require "src.render.shaders.outline_shader"
local tween = require "libs.tween"

local renderStats = false
local outlineShader = love.graphics.newShader(outline_shader)

local renderSystem = Concord.system({pool = {position, renderable, animation, state}})

function renderSystem:init()
    self.pusleDuration = 1
    self.pulseTimer = 0
    self.pulseAlpha = 0
    self.pulseAlphaPeak = 0.7
    self.pulseAlphaLow = 0.2
    self.outlinePulse = tween.new(self.pusleDuration, self, {pulseAlpha = self.pulseAlphaPeak}, "outInSine")
end

function renderSystem:draw()

    table.sort(self.pool, function(a, b)
        -- objects are always prioritized
        if a.metadata.type == "object" and b.metadata.type ~= "object" then
            return true
        elseif b.metadata.type == "object" and a.metadata.type ~= "object" then
            return false
        end

        -- -- flowers z - ordering
        -- if a.metadata.subType == "flower" and b.metadata.subType ~= "flower" then
        --     return a.position.screenY < b.position.screenY
        -- elseif b.metadata.subType == "flower" and a.metadata.subType ~= "flower" then
        --     return a.position.screenY > b.position.screenY
        -- end

        -- fallback

        -- Apply dynamic offset for mobs coming from underneath
        -- Higher screenY should render sooner
        local adjustedAY = a.position.screenY - a.position.screenY * 0.001
        local adjustedBY = b.position.screenY - b.position.screenY * 0.001

        -- fallback
        if adjustedAY == adjustedBY then
            return a.metadata.type < b.metadata.type
        end

        return adjustedAY < adjustedBY        
    end)

    for _, entity in ipairs(self.pool) do
        local state = entity.state
        local position = entity.position
        local renderable = entity.renderable
        
        if entity.metadata.type == 'flower' then
            local angle = love.math.noise((entity.position.x + entity.position.y) / 10 + love.timer.getTime() * 0.7) - 0.5
            love.graphics.setColor(1, 1, 1, 1)
        
            love.graphics.push()
            love.graphics.translate(
                position.screenX + RM.tileSize / 2, 
                position.screenY + RM.tileSize   
            )

            love.graphics.rotate(angle)

            love.graphics.clear()

            -- love.graphics.draw(
            --     RM.image,
            --     renderable.texture,
            --     500 / 2 - RM.tileSize / 2,
            --     500 / 2 - RM.tileSize / 2,
            --     0,
            --     RM.increaseFactor,
            --     RM.increaseFactor
            -- )

            love.graphics.draw(
                RM.image,
                renderable.texture,
                - RM.tileSize / 2,
                - RM.tileSize,
                0,
                RM.increaseFactor,
                RM.increaseFactor
            )

            love.graphics.pop()
        
        else
            if state.current == "dead" then
                goto continue
            end
    
            local animation = entity.animation
    
            love.graphics.push()
            love.graphics.translate(
                position.screenX + animation.translateX + RM.tileSize / 2, 
                position.screenY + animation.translateY + RM.tileSize / 2   
            )
    
            love.graphics.rotate(animation.rotation)
    
            if state.pickedUp then
                love.graphics.setColor(1, 1, 1, 0.4)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
    
            local offsetX = (1 - animation.flipX) / 2 * RM.tileSize
    
            if entity.metadata.type == 'animal' and sceneManager.currentScene.teamOutline then

                outlineShader:send("outlineSize", 0.5)
    
                local r, g, b = unpack(RM.teamColors[entity.metadata.teamID])

                outlineShader:send("outlineColor", {r, g, b, self.pulseAlpha})
    
                love.graphics.setShader(outlineShader)
                
            end

            love.graphics.draw(
                RM.image,
                renderable.texture,
                - RM.tileSize / 2 * animation.width + offsetX,
                - RM.tileSize / 2 * animation.height,
                0,
                RM.increaseFactor * animation.width * animation.flipX,
                RM.increaseFactor * animation.height
            )
    
            if entity.metadata.type == 'animal' and sceneManager.currentScene.teamOutline then
                love.graphics.setShader()
            end      
    
            love.graphics.pop()
    
            love.graphics.setColor(1, 1, 1, 1)
    
            ::continue::

        end
    end
    love.graphics.setCanvas()
end

function renderSystem:update(dt)
    if type(dt) ~= "number" then
        error("dt must be a number, but got " .. tostring(dt))
    end

    if self.outlinePulse then
        if self.outlinePulse:update(dt) then
            if self.pulseAlpha == self.pulseAlphaPeak then
                self.outlinePulse = tween.new(self.pusleDuration, self, {pulseAlpha = self.pulseAlphaLow}, "outInSine")
            elseif self.pulseAlpha == self.pulseAlphaLow then
                self.outlinePulse = tween.new(self.pusleDuration, self, {pulseAlpha = self.pulseAlphaPeak}, "outInSine")
            end    
        end
    end
end

return renderSystem