local Concord = require("libs.concord")
local RM = require("src.render.RenderManager"):getInstance()

local collider = Concord.component("collider", function(component)
    component.collidedWith = {}
    component.collisionGroups = {}
    component.width = RM.tileSize
    component.height = RM.tileSize
    component.disabled = false
    component.ignoreIds = {}
end)

return collider