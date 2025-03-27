local Concord = require("libs.concord")

local timers = Concord.component("timers", function(component)
    component.timers = {}
end)

return timers