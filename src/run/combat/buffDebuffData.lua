local buffDebuffData = {
    lucky_clover = {
        name = 'lucky_clover',
        description = 'You are lucky!',
        stats = {
            {'increase', 'crit', 1},
        },
        duration = 0
    },
    coffee = {
        name = 'coffee',
        description = 'Energy!',
        stats = {
            {'increase', 'moves', 1},
        },
        duration = 0
    }
}

return buffDebuffData