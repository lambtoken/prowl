local rates = {
    dungeon = {
        normal = {rate = 1, limit = 0},
        maze = {rate = 1, limit = 0},
    },
    -- arena = {
    --     normal = {rate = 0.2, limit = 1}
    -- },
    forest = {
        normal = {rate = 1, limit = 0},
        -- deep = {rate = 1, limit = 0}
    },
    desert = {
        normal = {rate = 1, limit = 0},
        ancient = {rate = 1, limit = 0}
    },
    glacial = {
        normal = {rate = 1, limit = 0},
        ice_spikes = {rate = 0.2, limit = 0}
    }
    ,
    swamp = {
        normal = {rate = 1, limit = 0}
    }
}

return rates