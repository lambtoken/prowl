local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local sceneM = require('src.scene.SceneManager'):getInstance()

local loading = Scene:new('loading')

function loading:enter()
    love.graphics.setFont(getFont('basis33', 50))
    self.textWidth = getFont('basis33', 50):getWidth("music by knotset")
    self.musicByX = math.floor(love.graphics.getWidth() / 2 - self.textWidth / 2)
    self.musicByY = math.floor(love.graphics.getHeight() / 2 - getFont('basis33', 50):getHeight() / 2)
    self.loadingTimer = 0
    self.loadingTime = 2
end

function loading:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(getFont('basis33', 50))
    love.graphics.print("music by knotset", self.musicByX, self.musicByY)
end

function loading:update(dt)
    self.loadingTimer = self.loadingTimer + dt

    if self.loadingTimer >= self.loadingTime then
        sceneM:switchScene('mainMenu')
    end
end

function loading:mousepressed(x, y, btn)
    if btn == 1 then sceneM:switchScene('mainMenu') end
end

return loading