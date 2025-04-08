local Concord = require("libs.concord")
local RM = require ('src.render.RenderManager'):getInstance()
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

            if not isInTable(colA.collisionGroups, entityB.metadata.type)
            or not isInTable(colB.collisionGroups, entityA.metadata.type) then
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
                        for index, value in ipairs(colA.ignoreIds) do
                            print("colA ids: ", value)
                        end
                        for index, value in ipairs(colB.ignoreIds) do
                            print("colB ids: ", value)
                        end
                        print(entityA.metadata.id, entityB.metadata.id)
                        print("collision1")
                        colA.onCollision(entityA, entityB)
                    end

                    if colB.onCollision then
                        for index, value in ipairs(colA.ignoreIds) do
                            print("colA ids: ", value)
                        end
                        for index, value in ipairs(colB.ignoreIds) do
                            print("colB ids: ", value)
                        end
                        print(entityA.metadata.id, entityB.metadata.id)
                        print("collision2")
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
    local tileSize = RM.tileSize

    local ax = posA.screenX + (colA.x or 0) * tileSize
    local ay = posA.screenY + (colA.y or 0) * tileSize
    local aw = (colA.width or 1) * tileSize
    local ah = (colA.height or 1) * tileSize

    local bx = posB.screenX + (colB.x or 0) * tileSize
    local by = posB.screenY + (colB.y or 0) * tileSize
    local bw = (colB.width or 1) * tileSize
    local bh = (colB.height or 1) * tileSize

    return ax < bx + bw and
           ax + aw > bx and
           ay < by + bh and
           ay + ah > by
end

return collisionSystem