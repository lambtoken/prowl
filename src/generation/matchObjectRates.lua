local rates = {
    dungeon = {
        normal = {
            {name = 'crate', rate = 10, limit = 0},
            {name = 'table', rate = 5, limit = 0},
            {name = 'vase', rate = 20, limit = 0},
            {name = 'apple', rate = 10, limit = 3},
            {name = 'barrel', rate = 5, limit = 0},
            {name = 'mouse_trap', rate = 10, limit = 2},
            {name = 'crack', rate = 3, limit = 1},
            {name = 'spikes', rate = 10, limit = 0},
            {name = 'bomb', rate = 2, limit = 3}
        },
        maze = {
            {name = 'crate', rate = 5, limit = 0},
            {name = 'vase', rate = 10, limit = 0},
            {name = 'barrel', rate = 10, limit = 0},
        },
        plus = {
            {name = 'crate', rate = 15, limit = 0},
            {name = 'table', rate = 5, limit = 0},
            {name = 'vase', rate = 15, limit = 0},
            {name = 'barrel', rate = 15, limit = 0}
        }
    },
    forest = {
        normal = {
            {name = 'spruce_tree', rate = 10, limit = 0},
            {name = 'oak_tree', rate = 5, limit = 0},
            {name = 'rock', rate = 10, limit = 0},
            {name = 'bear_trap', rate = 10, limit = 0},
            {name = 'mouse_trap', rate = 10, limit = 0},
            {name = 'apple', rate = 10, limit = 3},
            {name = 'mushroom', rate = 2, limit = 0}
        },
        dense = {
            {name = 'spruce_tree', rate = 20, limit = 0},
            {name = 'oak_tree', rate = 5, limit = 0},
            {name = 'rock', rate = 10, limit = 0},
            {name = 'mushroom', rate = 2, limit = 0}
        },
        gleam = {
            {name = 'spruce_tree', rate = 20, limit = 0},
            {name = 'oak_tree', rate = 5, limit = 0},
            {name = 'rock', rate = 10, limit = 0},
            {name = 'mushroom', rate = 2, limit = 0}
        }
    },
    desert = {
        normal = {
            {name = 'shrub', rate = 10, limit = 0},
            {name = 'cactus', rate = 10, limit = 0},
            {name = 'tumbleweed', rate = 10, limit = 0},
        },
    },
    glacial = {
        normal = {
            {name = 'spruce_tree', rate = 20, limit = 0},
            --{name = 'spruce_tree_snowy', rate = 10, limit = 0},
            {name = 'spruce_tree_snowy_partial', rate = 5, limit = 0},
            {name = 'ice_rock', rate = 10, limit = 0},
            {name = 'bear_trap', rate = 10, limit = 0},
        },
        ice_spikes = {
            {name = 'spruce_tree', rate = 20, limit = 0},
            {name = 'ice_rock', rate = 10, limit = 0},
            {name = 'ice_spike', rate = 10, limit = 0}
        }
    },
    plains = {
        normal = {
            {name = 'apple', rate = 5, limit = 0},
            {name = 'green_apple', rate = 10, limit = 0},
        },
    },
    dragon = {
        normal = {
            {name = 'vase', rate = 20, limit = 0},
            {name = 'apple', rate = 10, limit = 3},
            {name = 'small_pillar', rate = 2, limit = 0},
            {name = 'crack', rate = 3, limit = 1},
            {name = 'spikes', rate = 10, limit = 0},
        },
    },
    phoenix = {
        normal = {
            {name = 'vase', rate = 20, limit = 0},
            {name = 'apple', rate = 10, limit = 3},
            {name = 'small_pillar', rate = 2, limit = 0},
            {name = 'crack', rate = 3, limit = 1},
            {name = 'spikes', rate = 10, limit = 0},
        },
    },
    hydra = {
        normal = {
            { name = 'vase',         rate = 20, limit = 0 },
            { name = 'apple',        rate = 10, limit = 3 },
            { name = 'small_pillar', rate = 2,  limit = 0 },
            { name = 'crack',        rate = 3,  limit = 1 },
            { name = 'spikes',       rate = 10, limit = 0 },
        },
    },
    swamp = {
        normal = {
            -- FIX: object limit is causing a bug
            {name = 'lilypad', rate = 2, limit = 0},
        },
    }
}

return rates
