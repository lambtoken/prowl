local Concord = require("libs.concord")

local collisionSystem = Concord.system({pool = {collision, position}})

function collisionSystem:update()
    for i = 1, #self.pool do
        local entityA = self.pool[i]
        local posA = entityA.position
        local colA = entityA.collision

        colA.inCollisionWith = {}

        for j = i + 1, #self.pool do
            local entityB = self.pool[j]
            local posB = entityB.position
            local colB = entityB.collision

            if self:checkAABB(posA, colA, posB, colB) then
                
                if not colA.collidedWith[entityB] then

                    table.insert(colA.inCollisionWith, entityB)
                    table.insert(colB.inCollisionWith, entityA)

                    if entityA.onCollision then
                        entityA.onCollision(entityB)
                    end
                    if entityB.onCollision then
                        entityB.onCollision(entityA)
                    end

                    -- Mark as colliding
                    colA.collidedWith[entityB] = true
                    colB.collidedWith[entityA] = true
                end
            else
                if colA.collidedWith[entityB] then

                    if entityA.onExitCollision then
                        entityA.onExitCollision(entityB)
                    end
                    if entityB.onExitCollision then
                        entityB.onExitCollision(entityA)
                    end
                    
                    colA.collidedWith[entityB] = nil
                    colB.collidedWith[entityA] = nil
                end
            end
        end
    end
end

function collisionSystem:checkAABB(posA, colA, posB, colB)
    return posA.x < posB.x + colB.width and
           posA.x + colA.width > posB.x and
           posA.y < posB.y + colB.height and
           posA.y + colA.height > posB.y
end

return collisionSystem