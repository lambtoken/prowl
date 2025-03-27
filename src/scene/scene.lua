local class = require 'libs.middleclass'

local Scene = class("scene")

local idCounter = 0

function Scene:initialize(name)
    self.id = idCounter + 1
    idCounter = idCounter + 1
    self.name = name or 'untitled scene'
    self.enter = function() end
    self.update = function(dt) end
    self.draw = function() end
    self.exit = function() end
end

return Scene