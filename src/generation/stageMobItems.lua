local stageMobItems = {
    -- Stage 1
    {
        -- Match 1
        { chance = 0, min = 0, max = 1 },
        -- Match 2
        { chance = 0, min = 0, max = 1 },
        -- Match 3
        { chance = 0, min = 0, max = 1 },
        -- Match 4
        { chance = 0, min = 0, max = 1 },
        -- Match 5
        { chance = 0, min = 1, max = 1 },
        -- Match 6
        { chance = 0.1, min = 1, max = 2 },
        -- Match 7 (boss)
        { chance = 0.1, min = 1, max = 2 },
    },
    
    -- Stage 2
    {
        -- Match 1
        { chance = 0.2, min = 0, max = 1 },
        -- Match 2
        { chance = 0.2, min = 0, max = 1 },
        -- Match 3
        { chance = 0.3, min = 0, max = 2 },
        -- Match 4
        { chance = 0.3, min = 1, max = 2 },
        -- Match 5
        { chance = 0.4, min = 1, max = 2 },
        -- Match 6
        { chance = 0.4, min = 1, max = 3 },
        -- Match 7 (boss)
        { chance = 0.5, min = 1, max = 3 },
    },
    
    -- Stage 3
    {
        -- Match 1
        { chance = 0.5, min = 0, max = 2 },
        -- Match 2
        { chance = 0.5, min = 1, max = 2 },
        -- Match 3
        { chance = 0.6, min = 1, max = 2 },
        -- Match 4
        { chance = 0.7, min = 1, max = 2 },
        -- Match 5
        { chance = 0.8, min = 1, max = 3 },
        -- Match 6
        { chance = 1, min = 2, max = 3 },
        -- Match 7 (boss)
        { chance = 1, min = 2, max = 3 },
    }
}

return stageMobItems