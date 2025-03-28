local Concord = require("libs.concord")

local plant = Concord.component("plant", function(component)
    component.windInfluence = 1
end)

return plant