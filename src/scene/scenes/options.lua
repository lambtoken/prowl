local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local sceneM = require('src.scene.SceneManager'):getInstance()

local options = Scene:new('options')

function options:enter()
    love.graphics.setFont(getFont('basis33', 50))
    self.textWidth = getFont('basis33', 50):getWidth("options")
    self.musicByX = math.floor(love.graphics.getWidth() / 2 - self.textWidth / 2)
    self.musicByY = math.floor(love.graphics.getHeight() / 2 - getFont('basis33', 50):getHeight() / 2)
end

function options:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.print("options", self.musicByX, self.musicByY)
end

function options:keypressed(key)
    if key == 'escape' then
        sceneM:switchScene('mainMenu')
    end
end

function options:resize()
    self.musicByX = math.floor(love.graphics.getWidth() / 2 - self.textWidth / 2)
    self.musicByY = math.floor(love.graphics.getHeight() / 2 - getFont('basis33', 50):getHeight() / 2)
end


return options