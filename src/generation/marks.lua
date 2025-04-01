local marks = {
    -- delays the attack when stepped on
    echo = {
        name = "echo",
        description = "A mark that delays the attack.",
        data = {
            echoed = {},
        },
        passive = {
            onStepped = function(matchState, entity, mark)
                --table.insert(mark.data.echoed, entity.metadata.id)
                matchState.statusEffectSystem:giveStatusEffect(entity, mark, "disarm", 0)
            end,
            onStandBy = function(matchState, entity, mark)
                if #mark.data.echoed > 0 then
                    local entities = matchState.moveSystem:getByCoordinates(entity.position.x, entity.position.y, "animal")
                    for _, target in ipairs(entities) do
                        matchState.combatSystem:attack(entity, target)
                    end
                    mark.data.echoed = {}
                end
            end,  
        },
    },
    -- moves each stand by phase and gives a buff when stepped on
    living_mark = {
        name = "living mark",
        description = "A constantly moving mark that gives a buff when stepped on",
        passive = {
            onStepped = function(matchState, entity, mark)
                matchState.buffDebuffSystem:applyStatEffect(entity, mark,{{"increase", "atk", 1}}, 3)
            end,
            onStandBy = function(matchState, entity, mark)
                local freeSpots = matchState.moveSystem:getFreeSpots()
                if #freeSpots > 0 then
                    local spot = freeSpots[math.random(1, #freeSpots)]
                    matchState.positionSystem:move(mark, "tp", spot.x, spot.y)
                end
            end,
        },
    },
    -- moves to a random mark when stepped on
    blink_mark = {
        name = "blink mark",
        description = "A mark that moves to a random mark when stepped on",
        passive = {
            onStepped = function(matchState, entity, mark)
                local randomMark = matchState.markSystem:getRandomMark(mark)
                matchState.moveSystem:move(entity, "tp", randomMark.position.x, randomMark.position.y)
            end,
        },
    },
    -- pulls a random entity to the mark when the end turn is reached
    singularity_mark = {
        name = "singularity mark",
        description = "A mark that pulls a random entity to the mark when the end turn is reached",
        passive = {
            onEndTurn = function(matchState, entity, mark)
                local entities = matchState.moveSystem:getNearbyEntities(entity, "animal")
                local randomEntity = entities[math.random(1, #entities)]
                matchState.moveSystem:move(randomEntity, "displace", mark.position.x, mark.position.y)
            end
        }
    },
    -- sacrifice 1 hp for a random buff
    bloodletter_mark = {
        name = "bloodletter mark",
        description = "A mark that sacrifices 1 hp for a random buff",
        passive = {
            onStepped = function(matchState, entity, mark)
                matchState.combatSystem:dealDamage(entity, 1)
                SoundManager:playSound('bloodletter')
                
                local buffs = {
                    stat = "atk", amount = 1,
                    stat = "def", amount = 1,
                    stat = "crit", amount = 0.5
                }

                local randomBuff = buffs[math.random(1, #buffs)]

                matchState.buffDebuffSystem:applyStatEffect(entity, {{"increase", randomBuff.stat, randomBuff.amount}}, 3)
            end
        }
    },
}


return marks