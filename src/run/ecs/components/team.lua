local Concord = require("libs.concord")
local json = require("libs.json")

local team = Concord.component("team", function(c, type)
    c.type = type
    c.id = 1
end)

function team:serialize()
    return {type = self.type, self.id}
end

function team:deserialize(data)
    self.type = data.type
    self.id = data.id
end

return team