local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local adventureConfig = require 'src.run.stageConfig'
local RM = require ('src.render.RenderManager'):getInstance()
local sceneM = require('src.scene.SceneManager'):getInstance()
local gs = require('src.state.GameState'):getInstance()
local spriteTable = require 'src.render.spriteTable'
local hearts = require 'src.render.runHearts'
local noiseShader = love.graphics.newShader(require('src.render.shaders.noise_shader'))


local function nodeContains(to, node)
    for i, value in ipairs(to) do
        if value[1] == node[1] and value[2] == node[2] then
            return true
        end
    end

    return false
end


local runMap = Scene:new('runMap')

function runMap:mousepressed(x, y, button, istouch, presses)
    for i, col in ipairs(gs.run.stages[self.stage].nodes) do
        local yOffset = (adventureConfig.nodeIconSize * (adventureConfig.tallestCol - #col)) / 2 +
        (adventureConfig.nodeDistance * (adventureConfig.tallestCol - #col)) / 2
        for j, node in ipairs(col) do
            if node.screenX < x and node.screenX + adventureConfig.nodeIconSize > x and
                node.screenY < y and node.screenY + adventureConfig.nodeIconSize > y and button == 1 then
                if nodeContains(node.from, gs.run.currentNodeCoords) then
                    gs.currentMatchNode = node
                    sceneM:switchScene('match')
                end
            end
        end
    end
end

function runMap:enter(s)
    self.stage = gs.run.currentStage

    adventureConfig.tallestCol = math.max(unpack(adventureConfig.format))
    adventureConfig.mapWidth = #adventureConfig.format * adventureConfig.nodeIconSize +
    (#adventureConfig.format - 1) * adventureConfig.colDistance
    adventureConfig.mapHeight = adventureConfig.tallestCol * adventureConfig.nodeIconSize +
    (adventureConfig.tallestCol - 1) * adventureConfig.nodeDistance
    adventureConfig.mapX = math.floor(RM.windowWidth / 2) - math.floor(adventureConfig.mapWidth / 2)
    adventureConfig.mapY = math.floor(RM.windowHeight / 2) - math.floor(adventureConfig.mapHeight / 2)
    adventureConfig.iconSize = RM.spriteSize

    if adventureConfig.currentNode == nil then
        adventureConfig.currentNode = { 1, 1 }
    end

    if not gs.run then
        gs:newRun()
    end

    -- screenX and screenY
    for i, col in ipairs(gs.run.stages[self.stage].nodes) do
        local yOffset = (adventureConfig.nodeIconSize * (adventureConfig.tallestCol - #col)) / 2 +
        (adventureConfig.nodeDistance * (adventureConfig.tallestCol - #col)) / 2
        for j, node in ipairs(col) do
            local nodeX = adventureConfig.mapX + (i - 1) * adventureConfig.nodeIconSize +
            (i - 1) * adventureConfig.colDistance
            local nodeY = adventureConfig.mapY + (j - 1) * adventureConfig.nodeIconSize + yOffset +
            (j - 1) * adventureConfig.nodeDistance

            node.screenX = nodeX
            node.screenY = nodeY
        end
    end

    self.hearts = hearts:new(gs.run)
end

function runMap:update(dt)
    noiseShader:send("time", love.timer.getTime())
end

function runMap:mousemoved(x, y)
    for i, col in ipairs(gs.run.stages[self.stage].nodes) do
        for j, node in ipairs(col) do
            if j == 1 and i == 1 then
            end

            if node.screenX < x and node.screenX + adventureConfig.nodeIconSize > x and
                node.screenY < y and node.screenY + adventureConfig.nodeIconSize > y then
                adventureConfig.hoveredNode = node
                goto continue
            else
                adventureConfig.hoveredNode = nil
            end
        end
    end
    ::continue::
end

local c = love.graphics.newCanvas()


function runMap:draw(s)
    
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle('fill', 0, 0, RM.windowWidth, RM.windowHeight)
    love.graphics.setColor(1, 1, 1)
            
    for i, col in ipairs(gs.run.stages[self.stage].nodes) do
        local yOffset = (adventureConfig.nodeIconSize * (adventureConfig.tallestCol - #col)) / 2 +
        (adventureConfig.nodeDistance * (adventureConfig.tallestCol - #col)) / 2
        for j, node in ipairs(col) do
            local nodeX = adventureConfig.mapX + (i - 1) * adventureConfig.nodeIconSize +
            (i - 1) * adventureConfig.colDistance
            local nodeY = adventureConfig.mapY + (j - 1) * adventureConfig.nodeIconSize + yOffset +
            (j - 1) * adventureConfig.nodeDistance

            if node.to then
                for k, route in ipairs(node.to) do
                    local toNodeYOffset = (adventureConfig.nodeIconSize * (adventureConfig.tallestCol - #gs.run.stages[self.stage].nodes[i + 1])) /
                    2 +
                    (adventureConfig.nodeDistance * (adventureConfig.tallestCol - #gs.run.stages[self.stage].nodes[i + 1])) / 2

                    local toNodeX = adventureConfig.mapX + route[1] * adventureConfig.nodeIconSize +
                    (route[1] - 1) * adventureConfig.colDistance - adventureConfig.nodeIconSize / 2
                    local toNodeY = adventureConfig.mapY + (route[2] - 1) * adventureConfig.nodeIconSize + toNodeYOffset +
                    (route[2] - 1) * adventureConfig.nodeDistance + adventureConfig.nodeIconSize / 2

                    love.graphics.line(nodeX + adventureConfig.nodeIconSize / 2, nodeY + adventureConfig.nodeIconSize / 2,
                        toNodeX, toNodeY)
                end
            end


            -- set node background color accordingly
            if not nodeContains(node.from, gs.run.currentNodeCoords) then
                love.graphics.setColor(0.5, 0.4, 0.6)
            else
                love.graphics.setColor(0.6, 0.3, 0.6)
            end

            if node.passed then
                love.graphics.setColor(0.3, 0.3, 0.3)
            end

            love.graphics.rectangle(
                'fill',
                nodeX,
                nodeY,
                adventureConfig.nodeIconSize,
                adventureConfig.nodeIconSize
            )

            love.graphics.setColor(1, 1, 1, 1)

            if node.type ~= 'start' and node.type ~= 'end' then
                local quad
                if not node.passed then
                    quad = love.graphics.newQuad(spriteTable[node.spriteName][1] * RM.spriteSize,
                        spriteTable[node.spriteName][2] * RM.spriteSize, RM.spriteSize,
                        RM.spriteSize, RM.image)

                    love.graphics.draw(
                        RM.image,
                        quad,
                        adventureConfig.mapX + (i - 1) * adventureConfig.nodeIconSize +
                        (i - 1) * adventureConfig.colDistance,
                        adventureConfig.mapY + (j - 1) * adventureConfig.nodeIconSize + yOffset +
                        (j - 1) * adventureConfig.nodeDistance,
                        0,
                        adventureConfig.increaseFactor
                    )
                end

                if adventureConfig.hoveredNode == node then
                    quad = love.graphics.newQuad(spriteTable.node_select[1] * RM.spriteSize,
                        spriteTable.node_select[2] * RM.spriteSize, RM.spriteSize,
                        RM.spriteSize, RM.image)

                    love.graphics.draw(
                        RM.image,
                        quad,
                        adventureConfig.mapX + (i - 1) * adventureConfig.nodeIconSize +
                        (i - 1) * adventureConfig.colDistance,
                        adventureConfig.mapY + (j - 1) * adventureConfig.nodeIconSize + yOffset +
                        (j - 1) * adventureConfig.nodeDistance,
                        0,
                        adventureConfig.increaseFactor
                    )
                end
            end
        end

        if gs.run.currentNodeCoords[1] == i then
            if gs.run.starterSpecies then
                local quad = love.graphics.newQuad(
                    spriteTable[gs.run.starterSpecies][1] * RM.spriteSize,
                    spriteTable[gs.run.starterSpecies][2] * RM.spriteSize,
                    RM.spriteSize,
                    RM.spriteSize,
                    RM.image
                )

                love.graphics.draw(
                    RM.image,
                    quad,
                    adventureConfig.mapX + (gs.run.currentNodeCoords[1] - 1) * adventureConfig.nodeIconSize +
                    (gs.run.currentNodeCoords[1] - 1) * adventureConfig.colDistance,
                    adventureConfig.mapY + (gs.run.currentNodeCoords[2] - 1) * adventureConfig.nodeIconSize + yOffset +
                    (gs.run.currentNodeCoords[2] - 1) * adventureConfig.nodeDistance,
                    0,
                    adventureConfig.increaseFactor
                )
            end
        end
    end

    self.hearts:draw()
end

function runMap:exit() end

function runMap:keypressed(key)
    if key == 'escape' then
        sceneM:switchScene('mainMenu')
    end
end

return runMap
