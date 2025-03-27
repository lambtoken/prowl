local Concord = require("libs.concord")

local crowdControl = Concord.component("crowdControl", function(component)
    component.ccEffects = {}
    component.ccModifiers = {}
end)

return crowdControl