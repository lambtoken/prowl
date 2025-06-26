local stageMobLevels = {
    -- Stage 1
    {
        -- Match 1
        {levelUpChance = 0, negativeChance = 1, minLevel = 2, maxLevel = 2},
        -- Match 2
        {levelUpChance = 0, negativeChance = 0.8, minLevel = 2, maxLevel = 2},
        -- Match 3
        {levelUpChance = 0, negativeChance = 0.7, minLevel = 2, maxLevel = 2},
        -- Match 4
        {levelUpChance = 0.1, negativeChance = 0.5, minLevel = 2, maxLevel = 3},
        -- Match 5
        {levelUpChance = 0.2, negativeChance = 0.3, minLevel = 2, maxLevel = 3},
        -- Match 6
        {levelUpChance = 0.3, negativeChance = 0.2, minLevel = 2, maxLevel = 4},
        -- Match 7 (boss)
        {levelUpChance = 0.4, negativeChance = 0.1, minLevel = 2, maxLevel = 4},
    },
    -- Stage 2  
    {
        -- Match 1
        {levelUpChance = 0.5, negativeChance = 0, minLevel = 3, maxLevel = 4},
        -- Match 2
        {levelUpChance = 0.5, negativeChance = 0, minLevel = 3, maxLevel = 4},
        -- Match 3
        {levelUpChance = 0.6, negativeChance = 0, minLevel = 3, maxLevel = 4},
        -- Match 4
        {levelUpChance = 0.6, negativeChance = 0, minLevel = 3, maxLevel = 5},
        -- Match 5
        {levelUpChance = 0.7, negativeChance = 0, minLevel = 3, maxLevel = 5},
        -- Match 6
        {levelUpChance = 0.7, negativeChance = 0, minLevel = 3, maxLevel = 5},
        -- Match 7 (boss)
        {levelUpChance = 0.8, negativeChance = 0, minLevel = 3, maxLevel = 5},
    },
    -- Stage 3
    {
        -- Match 1
        {levelUpChance = 0.8, negativeChance = 0, minLevel = 4, maxLevel = 6},
        -- Match 2
        {levelUpChance = 0.8, negativeChance = 0, minLevel = 4, maxLevel = 6},
        -- Match 3
        {levelUpChance = 0.9, negativeChance = 0, minLevel = 4, maxLevel = 6},
        -- Match 4
        {levelUpChance = 1, negativeChance = 0, minLevel = 4, maxLevel = 7},
        -- Match 5
        {levelUpChance = 1, negativeChance = 0, minLevel = 5, maxLevel = 7},
        -- Match 6
        {levelUpChance = 1, negativeChance = 0, minLevel = 5, maxLevel = 7},
        -- Match 7 (boss)
        {levelUpChance = 1, negativeChance = 0, minLevel = 5, maxLevel = 8},
    }
}

-- Interpolate between anchor configs (tables with multiple fields)
local function interpolateConfigAnchors(anchorConfigs, maxLevel)
    -- anchorConfigs: { [level] = {levelUpChance=..., negativeChance=..., minLevel=..., maxLevel=...}, ... }
    local result = {}
    local anchors = {}
    for lvl, cfg in pairs(anchorConfigs) do
        table.insert(anchors, {level = lvl, config = cfg})
    end
    table.sort(anchors, function(a, b) return a.level < b.level end)
    for i = 1, #anchors - 1 do
        local a, b = anchors[i], anchors[i+1]
        for lvl = a.level, b.level - 1 do
            local t = (lvl - a.level) / (b.level - a.level)
            local interp = {}
            for k, v in pairs(a.config) do
                if type(v) == 'number' and type(b.config[k]) == 'number' then
                    interp[k] = v + (b.config[k] - v) * t
                else
                    interp[k] = v -- fallback: just copy
                end
            end
            result[lvl] = interp
        end
    end
    result[anchors[#anchors].level] = anchors[#anchors].config
    -- Fill up to maxLevel if needed
    if maxLevel and anchors[#anchors].level < maxLevel then
        for lvl = anchors[#anchors].level + 1, maxLevel do
            result[lvl] = anchors[#anchors].config
        end
    end
    return result
end

local function interpolateStages(anchors, numMatches)
    local stages = {}
    for i, anchorConfigs in ipairs(anchors) do
        local configs = interpolateConfigAnchors(anchorConfigs, numMatches)
        local stage = {}
        for match = 1, numMatches do
            stage[match] = configs[match]
        end
        stages[i] = stage
    end
    return stages
end

local anchors = {
    {
        [1] = {levelUpChance=0, negativeChance=1, minLevel=2, maxLevel=2},
        [5] = {levelUpChance=1, negativeChance=0, minLevel=4, maxLevel=7}
    },
    {
        [1] = {levelUpChance=0.5, negativeChance=0, minLevel=7, maxLevel=11},
        [5] = {levelUpChance=1, negativeChance=0, minLevel=9, maxLevel=14}
    },
    {
        [1] = {levelUpChance=0.8, negativeChance=0, minLevel=10, maxLevel=16},
        [5] = {levelUpChance=1, negativeChance=0, minLevel=15, maxLevel=18}
    }
}

stageMobLevels = interpolateStages(anchors, 7)

return stageMobLevels