local Concord = require("libs.concord")

local metadata = Concord.component("metadata", function(component, name, type)
    component.name = name or ""
    component.type = nil
    component.id = 0
end)

return metadata