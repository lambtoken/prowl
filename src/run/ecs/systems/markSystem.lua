local Concord = require("libs.concord")
local marks = require "src.generation.marks"

local MarkSystem = Concord.system({pool = {mark, position}})

function MarkSystem:init()
    self.marks = {}
end

function MarkSystem:getRandomMark(exclude)
    local marks = {}
    for _, mark in ipairs(self.pool) do
        if mark.metadata.type == "mark" and mark ~= exclude then
            table.insert(marks, mark)
        end
    end
    return marks[math.random(1, #marks)]
end

return MarkSystem
