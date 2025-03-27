local Concord = require("libs.concord")

local team = Concord.component("team", function(c, type)
    c.type = type
    c.id = 1
end)

return team