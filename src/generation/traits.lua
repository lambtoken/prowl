local traits = {
    -- P E R K S
    perks = {
        test = {
            -- perks give something positive to the player
            name = 'Plentiful Harvest',
            description = 'Gain 3 apples at the start of each match.',
            sprite = 'apple',
            effect = {
                afterGen = function(gameState)
                    local tiles = gameState.getSpawnPositions('bottom')

                    for _ = 1, 3 do
                        if #tiles > 0 then
                            local randomIndex = math.random(1, #tiles)
                            local tile = tiles[randomIndex]
                            gameState.match.moveSystem:spawnObject('apple', tile.x, tile.y)
                            table.remove(tiles, randomIndex)
                        end
                    end
                end,
            },
        },
    },

    -- C U R S E S
    curses = {
        grumpy_grove = {
            -- curses give something negative to the player

            -- instead of all this
            -- just give all trees the effect from effect registry

            name = 'Grumpy Grove',
            description = 'Hitting trees makes will agro them.',
            sprite = 'grumpy_grove',
            effect = {
                onHitAny = function(gameState, attacker, target)
                    -- iterate through all trees and set them to agro
                    if target.metadata.subType == "tree" and attacker.metadata.teamId == 0 then
                        -- target.metadata.targetId = attacker.metadata.id
                        gameState.aiManager:setAggro(target, attacker)
                    end

                end,
                onStandByAny = function(gameState, entity)
                    -- if the entity is a tree, set its onHit function
                    if entity.metadata.type == 'tree' then
                        if entity.metadata.target then
                            gameState.aiManager:setAggro(entity, entity.metadata.target)
                        end
                    end
                end
            },
        },
    },

    -- T W E A K S
    tweaks = {},
}

return traits