local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local sceneM = require('src.scene.SceneManager'):getInstance()
local gs = require('src.state.GameState'):getInstance()

local wonText = "You won!"
local lossText = "You lost."

local uiTest = Scene:new('uiTest')

function uiTest:enter()
    self.titleText = gs.run.runWon and wonText or lossText
    self.titleColor = gs.run.runWon and {0, 1, 0.3} or {1, 0, 0.3}
    self.textWidth = getFont('basis33', 50):getWidth(self.titleText)
    self:resize()
end

function uiTest:draw()
    love.graphics.setFont(getFont('basis33', 60))
    love.graphics.setColor(unpack(self.titleColor))
    love.graphics.print(self.titleText, self.outcomeX, self.outcomeY)
end

function uiTest:keypressed(key)
    if key == 'escape' then
        sceneM:switchScene('mainMenu')
        gs:removeRun()
    end
end

function uiTest:resize()
    self.outcomeX = math.floor(love.graphics.getWidth() / 2 - self.textWidth / 2)
    self.outcomeY = math.floor(love.graphics.getHeight() / 3 - getFont('basis33', 50):getHeight() / 3)
end


return uiTest