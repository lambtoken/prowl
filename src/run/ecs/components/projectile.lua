local Concord = require("libs.concord")

local projectile = Concord.component("projectile", function(c, speed, damping)
    c.speed = speed or 1
    c.damping = damping or 0.98
    c.angle = 0
end)

return projectile