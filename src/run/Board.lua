local class = require 'libs.middleclass'
local pretty = require 'libs.batteries.pretty'

local Board = class("Board", Node)

function Board:initialize()
    self.terrain = {}
    self.decorations = {}
    self.objects = {}
end

return Match