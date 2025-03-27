local Concord = require("libs.concord")

local tag = Concord.component("tag", function(component, name)
    component.name = name
end)

return tag