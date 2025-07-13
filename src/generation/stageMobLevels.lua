local stageMobLevels = nil

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
                    interp[k] = math.floor(interp[k] + 0.5) -- round to nearest integer
                else
                    interp[k] = v -- fallback: just copy
                end
            end
            result[lvl] = interp
        end
    end
    result[anchors[#anchors].level] = anchors[#anchors].config

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
        [1] = {levelUpChance=0, negativeChance=1, minLevel=1, maxLevel=2},
        [5] = {levelUpChance=1, negativeChance=0, minLevel=4, maxLevel=4}
        -- [5] = {levelUpChance=1, negativeChance=0, minLevel=2, maxLevel=4}
    },
    {
        [1] = {levelUpChance=0.5, negativeChance=0, minLevel=5, maxLevel=7},
        -- [1] = {levelUpChance=0.5, negativeChance=0, minLevel=4, maxLevel=6},
        [5] = {levelUpChance=1, negativeChance=0, minLevel=6, maxLevel=8}
    },
    {
        [1] = {levelUpChance=0.8, negativeChance=0, minLevel=8, maxLevel=9},
        [5] = {levelUpChance=1, negativeChance=0, minLevel=10, maxLevel=12}
    }
}

stageMobLevels = interpolateStages(anchors, 7)

return stageMobLevels