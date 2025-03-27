local class = require 'libs.middleclass'

local Node = class("node")

local idCounter = 0

function Node:initialize(type)
    self.id = idCounter + 1
    idCounter = idCounter + 1
    self.type = type
    self.mystery = false
    self.passed = false
    self.to = {}
    self.from = {}
    self.x = 0
    self.y = 0
    self.screenX = 0
    self.screenY = 0
    self.sprite = nil
    self.animation = nil
end

-- function Node:__tostring()
--     
-- end

return Node