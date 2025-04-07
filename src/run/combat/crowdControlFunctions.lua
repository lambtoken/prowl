local ccFunctions = {

    checkPath = function(matchState, targetX, targetY, dx, dy, distance)
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
return ccFunctions