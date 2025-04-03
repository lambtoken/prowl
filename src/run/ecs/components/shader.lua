local Concord = require("libs.concord")

local shader = Concord.component("shader", function(component)
    component.shaders = {}
    -- shader name, shader layer
    -- 0 = all, 1 = first, 2 = second, etc.
end)

return shader 