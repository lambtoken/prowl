local Concord = require("libs.concord")
local marks = require "src.generation.marks"

local MarkSystem = Concord.system({pool = {mark, position}})

function MarkSystem:init()
    self.marks = {}
end

return MarkSystem
