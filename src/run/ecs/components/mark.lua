local Concord = require("libs.concord")

local mark = Concord.component("mark", function(component, name)
    component.name = name
end)

return mark