local defaultMove = function(tx, ty, target, proj, dt)
    local damping = proj.projectile.damping
    local speed = proj.projectile.speed
    local pos = proj.position

    if target then
        local dx, dy = target.x - pos.x, target.y - pos.y
        local lengthSq = dx * dx + dy * dy
        if lengthSq > 0 then
            local factor = dt * speed / lengthSq
            pos.x = pos.x + dx * factor
            pos.y = pos.y + dy * factor
        end
    else
        pos.dirX = tx - pos.x
        pos.dirY = ty - pos.y
        local lengthSq = pos.dirX * pos.dirX + pos.dirY * pos.dirY
        if lengthSq > 0 then
            local factor = dt * speed / lengthSq
            pos.dirX = pos.dirX * factor
            pos.dirY = pos.dirY * factor
        end

        pos.x = pos.x + pos.dirX
        pos.y = pos.y + pos.dirY
    end

    speed = speed * damping
end

local DEFAULTS = {
    DAMPING = 0.98
}

local projectiles = {
    arrow = {
        speed = 2,
        dumping = DEFAULTS.DAMPING,
        moveFunction = function(matchState, self, dt)
            defaultMove(nil, nil, self.target, self, dt)
        end,
        onHit = function(matchState, entity, source)
            if matchState.combatSystem:isValidTarget(entity, source) then
                matchState.combatSystem:hit(entity, 1)
            end
        end
    },

    snowball = {
        speed = 1.5,
        moveFunction = function(matchState, self, dt)
            defaultMove(nil, nil, self.target, self, dt)
        end,
        onHit = function(matchState, entity, source)
            if matchState.combatSystem:isValidTarget(entity, source) then
                matchState.combatSystem:hit(entity, 1)
                matchState.crowdControlSystem:applyEffect(entity, "freeze", 2) -- Freeze for 2 seconds
            end
        end
    }
}

return projectiles