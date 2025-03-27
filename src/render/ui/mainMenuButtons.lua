local menus = require 'src.render.ui.menus'
local ButtonContainer = require 'src.render.ui.buttonContainer'
local RM = require ('src.render.RenderManager'):getInstance()
local SceneManager = require('src.scene.SceneManager'):getInstance()

local container = ButtonContainer:new()

for i, v in ipairs(menus.main.buttons) do
    container:addButton(v.text, v.callback)
end

container.buttons[2].disabled = true

container.width = menus.main.width

function container:resize(w, h)
    self.screenX = math.floor(w / 2) - math.floor(self.width / 2)
    self:calcHeight()
    self.screenY = math.floor(h / 2) - math.floor(self.height / 2) + math.floor((RM.logoImage:getHeight() * RM.logoScale) / 2)
    self:calcButtonsPos()
end

container:resize(RM.windowWidth, RM.windowHeight)

function container.runInProgress(bool)
    if bool then
        container.buttons[1].text = 'Continue run'
        container.buttons[1].callback = function() SceneManager:switchScene('runMap') end
    else
        container.buttons[1].text = 'New game'
        container.buttons[1].callback = function() SceneManager:switchScene('animalSelect') end
    end

    container.buttons[1]:adjust()
end

return container