local Concord = require("libs.concord")

local collider = Concord.component("collider", function(component)
    component.collidedWith = {}
    component.collisionGroups = {}
    component.x = 0
    component.y = 0
    component.width = 0.5
    component.height = 0.5
    component.disabled = false
    component.ignoreIds = {}
end)

return collider