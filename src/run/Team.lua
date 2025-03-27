local class = require 'libs.middleclass'

local Team = class("team")

function Team:initialize(type)
    self.agentType = type or 'bot' -- can be 'player' or 'bot'
    self.members = {}
    self.maxSize = 5
    self.alive = true
    self.actions = 0
    self.restCounter = 0
    self.rest = true
end

function Team:getSize()
    return #self.members
end

function Team:addMember(animal)
    if #self.members > self.maxSize then
        return
    end

    table.insert(self.members, animal)
end

function Team:isAlive()
    for i, member in ipairs(self.members) do
        if member.stats.hp > 0 then
            -- use concord getComponent method
            return true
        end
    end
    return false
end

function Team:setAliveState(bool)
    self.alive = bool
end


return Team