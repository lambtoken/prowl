local Concord = require("libs.concord")

local buffDebuff = Concord.component("buffDebuff", function(component)
    component.effects = {}
end)

return buffDebuff