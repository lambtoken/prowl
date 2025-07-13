local stageMobItems = nil

local function interpolateItemConfigAnchors(anchorConfigs, numMatches)
    local result = {}
    local anchors = {}
    for match, cfg in pairs(anchorConfigs) do
        table.insert(anchors, {match = match, config = cfg})
    end
    table.sort(anchors, function(a, b) return a.match < b.match end)
    
    for i = 1, #anchors - 1 do
        local a, b = anchors[i], anchors[i+1]
        for match = a.match, b.match - 1 do
            local t = (match - a.match) / (b.match - a.match)
            local interp = {
                chance = a.config.chance + (b.config.chance - a.config.chance) * t,
                min = math.floor(a.config.min + (b.config.min - a.config.min) * t + 0.5),
                max = math.floor(a.config.max + (b.config.max - a.config.max) * t + 0.5)
            }
            result[match] = interp
        end
    end
    result[anchors[#anchors].match] = anchors[#anchors].config

    local lastMatch = anchors[#anchors].match
    if lastMatch < numMatches then
        for match = lastMatch + 1, numMatches do
            result[match] = anchors[#anchors].config
        end
    end
    
    return result
end

local function interpolateItemStages(anchors, numMatches)
    local stages = {}
    for stageIdx, anchorConfigs in ipairs(anchors) do
        local configs = interpolateItemConfigAnchors(anchorConfigs, numMatches)
        local stage = {}
        for match = 1, numMatches do
            stage[match] = configs[match]
        end
        stages[stageIdx] = stage
    end
    return stages
end

local itemAnchors = {
    -- Stage 1 anchors
    {
        [1] = { chance = 0, min = 1, max = 1 },
        [5] = { chance = 0, min = 1, max = 1 },
        [7] = { chance = 0.1, min = 1, max = 1 }
    },
    
    -- Stage 2 anchors
    {
        [1] = { chance = 0.2, min = 1, max = 2 },
        [4] = { chance = 0.3, min = 2, max = 3 },
        [7] = { chance = 0.3, min = 2, max = 4 }
    },
    
    -- Stage 3 anchors
    {
        [1] = { chance = 0.4, min = 2, max = 3 },
        [4] = { chance = 0.5, min = 3, max = 4 },
        [7] = { chance = 0.6, min = 4, max = 5 }
    }
}

stageMobItems = interpolateItemStages(itemAnchors, 7)

return stageMobItems