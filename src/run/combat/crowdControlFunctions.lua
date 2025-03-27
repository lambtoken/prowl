return {
    
    calculateKnockbackPosition = function(matchState, sourceX, sourceY, targetX, targetY, knockbackDistance, terrain) 
        local dx = targetX - sourceX
        local dy = targetY - sourceY

        dx = dx ~= 0 and (dx / math.abs(dx)) or 0
        dy = dy ~= 0 and (dy / math.abs(dy)) or 0

        local finalX, finalY = targetX, targetY
        
        for i = 1, knockbackDistance do
            local nextX = finalX + dx
            local nextY = finalY + dy
            
            if not matchState:isSteppable(nextX, nextY) then
                break
            end

            finalX = nextX
            finalY = nextY
        end

        return finalX, finalY
    end,


    calculatePullPosition = function(matchState, sourceX, sourceY, targetX, targetY, pullDistance, terrain) 
        local dx = sourceX - targetX
        local dy = sourceY - targetY

        dx = dx ~= 0 and (dx / math.abs(dx)) or 0
        dy = dy ~= 0 and (dy / math.abs(dy)) or 0

        local finalX, finalY = targetX, targetY
        
        for i = 1, pullDistance do
            local nextX = finalX + dx
            local nextY = finalY + dy
            
            if not terrain:isSteppable(nextX, nextY) then
                break  
            end

            finalX = nextX
            finalY = nextY
        end

        return finalX, finalY
    end,


    calculatePerpendicularPosition = function(matchState, sourceX, sourceY, targetX, targetY, distance, terrain, direction)
        local dx = targetX - sourceX
        local dy = targetY - sourceY
    
        if direction == "left" then
            dx, dy = dy, -dx  -- swapping and negating for 90 degrees counter-clockwise
        elseif direction == "right" then
            dx, dy = -dy, dx  -- same but for 90 degrees clockwise  
        end
    
        dx = dx ~= 0 and (dx / math.abs(dx)) or 0
        dy = dy ~= 0 and (dy / math.abs(dy)) or 0

        local finalX, finalY = targetX, targetY
        
        for i = 1, distance do
            local nextX = finalX + dx
            local nextY = finalY + dy
            
            if not matchState:isSteppable(nextX, nextY) then
                break  
            end

            finalX = nextX
            finalY = nextY
        end

        return finalX, finalY
    end
    
}