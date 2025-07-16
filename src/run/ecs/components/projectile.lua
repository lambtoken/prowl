local Concord = require("libs.concord")

local projectile = Concord.component("projectile", function(c, speed, damping)
    c.speed = speed or 1
    c.damping = damping or 0.98
    c.angle = 0
    c.despawnTime = 3.0 -- Default despawn time in seconds
    c.despawnTimerStarted = false
end)

return projectile