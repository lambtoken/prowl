local Concord = require("libs.concord")

local collision = Concord.component("collision", function(component)
    component.inCollisionWith = {}
    component.collisionGroups = {}
    component.width = 16
    component.height = 16
end)

return collision