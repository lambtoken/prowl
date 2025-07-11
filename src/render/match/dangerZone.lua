local spriteTable = require 'src.render.spriteTable'
local RM = require('src.render.RenderManager'):getInstance()
local GameState = require('src.state.GameState'):getInstance()


function drawCurvedArrow(x1, y1, x2, y2)
    -- Calculate direction vector
    local dx = x2 - x1
    local dy = y2 - y1
    local len = math.sqrt(dx*dx + dy*dy)
    
    -- Calculate perpendicular vector for curvature
    local perpX = -dy/len * 50  -- 50 controls curvature amount
    local perpY = dx/len * 50
    
    -- Control points for cubic bezier curve
    local cx1 = x1 + dx/3 + perpX
    local cy1 = y1 + dy/3 + perpY
    local cx2 = x1 + 2*dx/3 + perpX
    local cy2 = y1 + 2*dy/3 + perpY
    
    -- Draw the curved line
    love.graphics.setLineWidth(2)
    love.graphics.line(bezierCurve(x1,y1, cx1,cy1, cx2,cy2, x2,y2, 20))
    
    -- Calculate arrowhead points
    local angle = math.atan2(y2 - cy2, x2 - cx2)
    local arrowSize = 25
    
    local arrowX1 = x2 - arrowSize * math.cos(angle - math.pi/6)
    local arrowY1 = y2 - arrowSize * math.sin(angle - math.pi/6)
    
    local arrowX2 = x2 - arrowSize * math.cos(angle + math.pi/6)
    local arrowY2 = y2 - arrowSize * math.sin(angle + math.pi/6)
    
    -- Draw arrowhead
    love.graphics.polygon("fill", x2, y2, arrowX1, arrowY1, arrowX2, arrowY2)
end

-- Helper function to generate points for cubic bezier curve
function bezierCurve(x1,y1, x2,y2, x3,y3, x4,y4, segments)
    local points = {}
    for i = 0, segments do
        local t = i / segments
        local mt = 1 - t
        local x = mt*mt*mt*x1 + 3*mt*mt*t*x2 + 3*mt*t*t*x3 + t*t*t*x4
        local y = mt*mt*mt*y1 + 3*mt*mt*t*y2 + 3*mt*t*t*y3 + t*t*t*y4
        table.insert(points, x)
        table.insert(points, y)
    end
    return points
end


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


return function(enemyMoves, hoveredTileX, hoveredTileY)
    RM:pushShader("wobble")
    RM:sendUniform("time", love.timer.getTime())
    RM:sendUniform("quadInfo", quadInfo)

    for _, moves in pairs(enemyMoves) do
        local move = moves.main
        if move.x == hoveredTileX and move.y == hoveredTileY then
            move = moves.alt
        end

        local entity = moves.main.entity

        local x = move.x * RM.tileSize
        local y = move.y * RM.tileSize
        love.graphics.setColor(1, 0, 0, 0.8)
        drawCurvedArrow(entity.position.screenX + RM.tileSize / 2, entity.position.screenY + RM.tileSize / 2, x + RM.tileSize / 2, y + RM.tileSize / 2)
        love.graphics.setColor(1, 1, 1, 0.7)
        local atk_pattern = entity.stats.currentPatterns.atkPattern
        for i, row in ipairs(atk_pattern) do
            for j, cell in ipairs(row) do
                if cell == 1 then
                    local atk_y = move.y + i - math.ceil(#atk_pattern / 2)
                    local atk_x = move.x + j - math.ceil(#row / 2)
                    if atk_y >= 0 and atk_y < GameState.match.height and atk_x >= 0 and atk_x < GameState.match.width then
                        love.graphics.draw(RM.image, danger_quad, atk_x * RM.tileSize, atk_y * RM.tileSize, 0, RM.increaseFactor)
                    end
                end
            end
        end
    end

    RM:popShader()
end