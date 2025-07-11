local Concord = require("libs.concord")
local json = require("libs.json")

-- remember to add agent type per animal so we can have helper animals in player team
local team = Concord.component("team", function(c, id)
    c.teamId = id
end)

function team:serialize()
    return {type = self.type, self.id}
end

function team:deserialize(data)
    self.type = data.type
    self.id = data.id
end

return team