local defaultMove = function(entity, dt)
    assert(entity.projectile, "Projectile component not found")

    local damping = entity.projectile.damping
    local speed = entity.projectile.speed
    local pos = entity.position
    local targetX = entity.projectile.targetX
    local targetY = entity.projectile.targetY

    if targetX and targetY then
        local dx, dy = targetX - pos.x, targetY - pos.y
        local lengthSq = dx * dx + dy * dy
        if lengthSq > 0 then
            local factor = dt * speed / lengthSq
            pos.x = pos.x + dx * factor
            pos.y = pos.y + dy * factor
        end
    else
        pos.dirX = targetX - pos.x
        pos.dirY = targetY - pos.y
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

defaultMove = function(entity, dt)
    assert(entity.projectile, "Projectile component not found")

    local damping = entity.projectile.damping
    local speed = entity.projectile.speed
    local pos = entity.position
    local targetX = entity.projectile.targetX
    local targetY = entity.projectile.targetY

    if targetX and targetY then
        local dx, dy = targetX - pos.x, targetY - pos.y
        local lengthSq = dx * dx + dy * dy
        if lengthSq > 0.2 then
            -- speed should be tile per second
            local normalIzed = math.sqrt(lengthSq)
            local normalizedX = dx / normalIzed
            local normalizedY = dy / normalIzed
            pos.x = pos.x + normalizedX * speed
            pos.y = pos.y + normalizedY * speed
            speed = speed * damping
        end
    end

end

function followTargetInstant(entity, dt)
    local pos = entity.position
    local targetX = entity.projectile.targetX
    local targetY = entity.projectile.targetY
    pos.x = targetX
    pos.y = targetY
end

local DEFAULTS = {
    DAMPING = 0.98,
    SPEED = 0.5,
}

local projectiles = {
    arrow = {
        speed = DEFAULTS.SPEED,
        damping = DEFAULTS.DAMPING,
        moveFunction = defaultMove,
        onHit = function(matchState, source, target)
            if target.metadata.type == "animal" then
                matchState.combatSystem:hit(target, 1)
                source.collider.disabled = true
                matchState.animationSystem:playAnimation(source, "trigger_death")
            end
            
        end
    },

    snowball = {
        speed = 1.5,
        damping = DEFAULTS.DAMPING,
        moveFunction = defaultMove,
        onHit = function(matchState, source, target)
            if matchState.combatSystem:isValidTarget(target, source) then
                matchState.combatSystem:hit(target, 1)
                matchState.crowdControlSystem:applyEffect(target, "freeze", 2) -- Freeze for 2 seconds
            end
        end
    }
}

return projectiles