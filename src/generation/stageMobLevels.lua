local stageMobLevels = {
    -- Stage 1
    {
        -- Match 1
        {levelUpChance = 0, negativeChance = 0.6, minLevel = 2, maxLevel = 2},
        -- Match 2
        {levelUpChance = 0.1, negativeChance = 0.5, minLevel = 2, maxLevel = 2},
        -- Match 3
        {levelUpChance = 0.1, negativeChance = 0.4, minLevel = 2, maxLevel = 2},
        -- Match 4
        {levelUpChance = 0.2, negativeChance = 0.4, minLevel = 2, maxLevel = 3},
        -- Match 5
        {levelUpChance = 0.3, negativeChance = 0.3, minLevel = 2, maxLevel = 3},
        -- Match 6
        {levelUpChance = 0.4, negativeChance = 0.2, minLevel = 2, maxLevel = 4},
        -- Match 7 (boss)
        {levelUpChance = 0.5, negativeChance = 0.1, minLevel = 2, maxLevel = 4},
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

return stageMobLevels