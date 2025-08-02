local Concord = require("libs.concord")
local RM = require ('src.render.RenderManager'):getInstance()
local getFont = require "src.render.getFont"
local sceneManager = require("src.scene.SceneManager"):getInstance()
local outline_shader = require "src.render.shaders.outline_shader"
local tween = require "libs.tween"

local outlineShader = love.graphics.newShader(outline_shader)

local renderSystem = Concord.system({pool = {"position", "renderable", "shader"}})

local drawColliders = false

function renderSystem:init()
    self.pusleDuration = 0.75
    self.pulseTimer = 0
    self.pulseAlpha = 0
    self.pulseAlphaPeak = 0.8
    self.pulseAlphaLow = 0.5
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
                love.graphics.setColor(1, 1, 1, 0.3)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
            
            local offsetX = (1 - renderable.transform.flipX) / 2 * textureSize
            
            for index, layer in ipairs(renderable.layers) do
                

                if entity.shader then
                    for _, shader in ipairs(entity.shader.shaders) do
                        RM:pushShader(shader.name)
                        RM:sendUniform("time", love.timer.getTime())
                        if shader.name == "wobble" and layer.texture then
                            local quad = layer.texture
                            local x, y, width, height = quad:getViewport()
                            local textureWidth, textureHeight = RM.image:getDimensions()
                            
                            local quadInfo = {
                                x / textureWidth,
                                y / textureHeight,
                                width / textureWidth,
                                height / textureHeight
                            }
                            
                            RM:sendUniform("quadInfo", quadInfo)
                        end
                    end
                end

                -- if entity.metadata.type == 'animal' then
                --     RM:pushShader("outline")
                --     RM:sendUniform("outlineWidth", 1)
                --     local r, g, b = unpack(RM.teamColors[entity.team.teamId])
                    
                --     local teamColorInfluence = self.pulseAlpha * 0.75
                --     local teamColorMaxSaturation = 0.5
                --     local finalR = (1 - teamColorInfluence) * 1 + teamColorInfluence * r * teamColorMaxSaturation
                --     local finalG = (1 - teamColorInfluence) * 1 + teamColorInfluence * g * teamColorMaxSaturation
                --     local finalB = (1 - teamColorInfluence) * 1 + teamColorInfluence * b * teamColorMaxSaturation
                   
                --     local alphaAmount = 0.4

                --     local alpha = alphaAmount + self.pulseAlpha * (1 - alphaAmount)
                    
                --     RM:sendUniform("outlineColor", {finalR, finalG, finalB, alpha})
                -- end

                love.graphics.draw(
                    RM.image,
                    layer.texture,
                    - textureSize / 2 * layer.transform.scaleX + offsetX,
                    - textureSize / 2 * layer.transform.scaleY,
                    0,
                    RM.increaseFactor * layer.transform.scaleX * renderable.transform.flipX,
                    RM.increaseFactor * layer.transform.scaleY
                )

                if #entity.shader.shaders > 0 then
                    RM:popShader(#entity.shader.shaders)
                end

            end

            love.graphics.pop()
            
            if entity.metadata.type == 'animal' then 
                RM:popShader()

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
            love.graphics.rectangle("line", entity.position.screenX + entity.collider.x * RM.tileSize, entity.position.screenY + entity.collider.y * RM.tileSize, entity.collider.width * RM.tileSize, entity.collider.height * RM.tileSize)
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
                self.outlinePulse = tween.new(self.pusleDuration, self, {pulseAlpha = self.pulseAlphaLow}, "outSine")
            elseif self.pulseAlpha == self.pulseAlphaLow then
                self.outlinePulse = tween.new(self.pusleDuration, self, {pulseAlpha = self.pulseAlphaPeak}, "inSine")
            end    
        end
    end

end

return renderSystem