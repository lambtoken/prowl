local Concord = require("libs.concord")
local statusDefaults = require "src.run.ecs.defaults.statusDefaults"

local status = Concord.component("status", function(component)
    component.canAttack = statusDefaults.canAttack
    component.canMove = statusDefaults.canMove
    component.canUseAbilities = statusDefaults.canUseAbilities
    component.isDisplaceable = statusDefaults.isDisplaceable
    component.isTargetable = statusDefaults.isTargetable
    component.isInvulnerable = statusDefaults.isInvulnerable
    component.isJammed = statusDefaults.isJammed -- should i do this on the level of the item?
    component.effects = {}
end)

return status