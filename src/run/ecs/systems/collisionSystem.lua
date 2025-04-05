local Concord = require("libs.concord")
local isInTable = require("src.utility.isInTable")

local collisionSystem = Concord.system({pool = {"collider", "position"}})

function collisionSystem:update()
    for i, entityA in ipairs(self.pool) do
        local posA = entityA.position
        local colA = entityA.collider

        if colA.disabled then
            goto continue
        end

        colA.collidedWith = {}

        for j, entityB in ipairs(self.pool) do
            if entityA == entityB then
                goto continue2
            end
    
            local posB = entityB.position
            local colB = entityB.collider

            if isInTable(colA.ignoreIds, entityB.metadata.id)
            or isInTable(colB.ignoreIds, entityA.metadata.id) then
                goto continue2
            end
            
            if colB.disabled or colA.disabled then
                goto continue2
            end
            
            if self:checkAABB(posA, colA, posB, colB) then
                
                if not colA.collidedWith[entityB.metadata.id] then

                    table.insert(colA.collidedWith, entityB.metadata.id)
                    table.insert(colB.collidedWith, entityA.metadata.id)

                    if colA.onCollision then
                        colA.onCollision(entityA, entityB)
                    end
                    if colB.onCollision then
                        colB.onCollision(entityB, entityA)
                    end

                    -- Mark as colliding
                    colA.collidedWith[entityB.metadata.id] = true
                    colB.collidedWith[entityA.metadata.id] = true
                end
            else
                if colA.collidedWith[entityB.metadata.id] then

                    if colA.onExitCollision then
                        colA.onExitCollision(entityB)
                    end
                    if colB.onExitCollision then
                        colB.onExitCollision(entityA)
                    end
                    
                    colA.collidedWith[entityB.metadata.id] = nil
                    colB.collidedWith[entityA.metadata.id] = nil
                end
            end
            ::continue2::
        end
        ::continue::
    end
end

function collisionSystem:checkAABB(posA, colA, posB, colB)
    return posA.screenX < posB.screenX + colB.width and
           posA.screenX + colA.width > posB.screenX and
           posA.screenY < posB.screenY + colB.height and
           posA.screenY + colA.height > posB.screenY
end

return collisionSystem