local spriteTable = require 'src.render.spriteTable'
local RM = require('src.render.RenderManager'):getInstance()
local GameState = require('src.state.GameState'):getInstance()

local move_quad = love.graphics.newQuad(spriteTable['move_zone'][1] * RM.spriteSize, spriteTable['move_zone'][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
local danger_quad = love.graphics.newQuad(spriteTable['atk_zone'][1] * RM.spriteSize, spriteTable['atk_zone'][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)

local x, y, width, height = danger_quad:getViewport()
local textureWidth, textureHeight = RM.image:getDimensions()

-- Convert to texture coordinates (0-1 range)
local quadInfo = {
    x / textureWidth,
    y / textureHeight,
    width / textureWidth,
    height / textureHeight
}


return function(moves)
    
    RM:pushShader("wobble")
    RM:sendUniform("time", love.timer.getTime())
    RM:sendUniform("quadInfo", quadInfo)
    
    for _, value in ipairs(moves) do
        local x = value.x * RM.tileSize
        local y = value.y * RM.tileSize
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.draw(RM.image, move_quad, x, y, 0, RM.increaseFactor)
        
        local atk_pattern = value.entity.stats.currentPatterns.atkPattern
        
        for i, row in ipairs(atk_pattern) do
            for j, cell in ipairs(row) do
                if cell == 1 then
                    local atk_y = value.y + i - math.ceil(#atk_pattern / 2)
                    local atk_x = value.x + j - math.ceil(#row / 2)
                    if atk_y >= 0 and atk_y < GameState.match.height and atk_x >= 0 and atk_x < GameState.match.width then
                        love.graphics.draw(RM.image, danger_quad, atk_x * RM.tileSize, atk_y * RM.tileSize, 0, RM.increaseFactor)     
                    end
                end
            end
        end
    end

    RM:popShader()
end