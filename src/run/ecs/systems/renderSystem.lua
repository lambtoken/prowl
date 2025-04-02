local Concord = require("libs.concord")
local RM = require ('src.render.RenderManager'):getInstance()
local getFont = require "src.render.getFont"
local sceneManager = require("src.scene.SceneManager"):getInstance()
local outline_shader = require "src.render.shaders.outline_shader"
local tween = require "libs.tween"

local renderStats = false
local outlineShader = love.graphics.newShader(outline_shader)

local renderSystem = Concord.system({pool = {"position", "renderable"}})

local drawColliders = false

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
        
            local textureSize = renderable.width * RM.increaseFactor

            love.graphics.push()
            
            love.graphics.translate(
                position.screenX + textureSize / 2, 
                position.screenY + textureSize   
            )

            love.graphics.rotate(angle)
            
            for index, layer in ipairs(renderable.layers) do

                love.graphics.draw(
                    RM.image,
                    layer.texture,
                    - textureSize / 2,
                    - textureSize,
                    0,
                    RM.increaseFactor,
                    RM.increaseFactor
                )

            end
            love.graphics.pop()
            
        else
            if state and state.current == "dead" then
                goto continue
            end
    
            local renderable = entity.renderable
            
            local textureSize = renderable.width * RM.increaseFactor

            love.graphics.push()

            love.graphics.translate(
                position.screenX + renderable.transform.translateX + textureSize / 2, 
                position.screenY + renderable.transform.translateY + textureSize / 2   
            )

            love.graphics.rotate(renderable.transform.rotation)
            
            if entity.projectile then
                love.graphics.rotate(entity.projectile.angle)
            end

            if state and state.pickedUp then
                love.graphics.setColor(1, 1, 1, 0.4)
            elseif entity.metadata.type == "mark" then
                love.graphics.setColor(1, 1, 1, 0.6)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
            
            local offsetX = (1 - renderable.transform.flipX) / 2 * textureSize
            
            for index, layer in ipairs(renderable.layers) do
                
                if entity.metadata.type == 'animal' and sceneManager.currentScene.teamOutline then
                    outlineShader:send("outlineSize", textureSize/16 * 0.25)
                    local r, g, b = unpack(RM.teamColors[entity.metadata.teamID])
                    outlineShader:send("outlineColor", {r, g, b, self.pulseAlpha})
                    love.graphics.setShader(outlineShader)
                end

                love.graphics.draw(
                    RM.image,
                    layer.texture,
                    - textureSize / 2 * layer.transform.scaleX + offsetX,
                    - textureSize / 2 * layer.transform.scaleY,
                    0,
                    RM.increaseFactor * layer.transform.scaleX * renderable.transform.flipX,
                    RM.increaseFactor * layer.transform.scaleY
                )
        
            end

            love.graphics.pop()
            
            if entity.metadata.type == 'animal' then 
                if sceneManager.currentScene.teamOutline then
                    love.graphics.setShader()
                end

                local bgFont = getFont("basis33", 38)
                local font = getFont("basis33", 35)
                love.graphics.setFont(bgFont)
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.print(entity.stats.current.hp, entity.position.screenX + textureSize / 2 - bgFont:getWidth(entity.stats.current.hp) / 2, entity.position.screenY + textureSize - bgFont:getHeight())
                love.graphics.setFont(font)
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.print(entity.stats.current.hp, entity.position.screenX + textureSize / 2 - font:getWidth(entity.stats.current.hp) / 2, entity.position.screenY + textureSize - font:getHeight())
            end
    
            love.graphics.setColor(1, 1, 1, 1)
    
            ::continue::

        end
        if drawColliders and entity.collider then
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("line", entity.position.screenX, entity.position.screenY, entity.collider.width, entity.collider.height)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
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