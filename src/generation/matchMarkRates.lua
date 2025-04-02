local MatchMarks = {
    -- REGULAR ROOMS
    -- comment out all except blink mark and living mark
    dungeon = {
        normal = {
            -- {name = 'echo', rate = 8, limit = 0},
            {name = 'living_mark', rate = 12, limit = 0},
            {name = 'blink_mark', rate = 10, limit = 0},
            -- {name = 'singularity_mark', rate = 5, limit = 0},
            -- {name = 'bloodletter_mark', rate = 15, limit = 0}
        },
        maze = {
            -- {name = 'echo', rate = 12, limit = 0},
            {name = 'living_mark', rate = 8, limit = 0},
            {name = 'blink_mark', rate = 15, limit = 0},
            -- {name = 'singularity_mark', rate = 10, limit = 0},
            -- {name = 'bloodletter_mark', rate = 5, limit = 0}
        },
        plus = {
            -- {name = 'echo', rate = 10, limit = 0},
            {name = 'living_mark', rate = 15, limit = 0},
            {name = 'blink_mark', rate = 8, limit = 0},
            -- {name = 'singularity_mark', rate = 12, limit = 0},
            -- {name = 'bloodletter_mark', rate = 10, limit = 0}
        }
    },
    forest = {
        normal = {
            -- {name = 'echo', rate = 15, limit = 0},
            {name = 'living_mark', rate = 12, limit = 0},
            {name = 'blink_mark', rate = 8, limit = 0},
            -- {name = 'singularity_mark', rate = 5, limit = 0},
            -- {name = 'bloodletter_mark', rate = 10, limit = 0}
        },
        dense = {
            -- {name = 'echo', rate = 12, limit = 0},
            {name = 'living_mark', rate = 15, limit = 0},
            {name = 'blink_mark', rate = 10, limit = 0},
            -- {name = 'singularity_mark', rate = 8, limit = 0},
            -- {name = 'bloodletter_mark', rate = 5, limit = 0}
        },
        gloam = {
            -- {name = 'echo', rate = 10, limit = 0},
            {name = 'living_mark', rate = 8, limit = 0},
            {name = 'blink_mark', rate = 15, limit = 0},
            -- {name = 'singularity_mark', rate = 12, limit = 0},
            -- {name = 'bloodletter_mark', rate = 5, limit = 0}
        }
    },
    glacial = {
        normal = {
            -- {name = 'echo', rate = 5, limit = 0},
            {name = 'living_mark', rate = 10, limit = 0},
            {name = 'blink_mark', rate = 15, limit = 0},
            -- {name = 'singularity_mark', rate = 8, limit = 0},
            -- {name = 'bloodletter_mark', rate = 12, limit = 0}
        },
        ice_spikes = {
            -- {name = 'echo', rate = 8, limit = 0},
            {name = 'living_mark', rate = 5, limit = 0},
            {name = 'blink_mark', rate = 12, limit = 0},
            -- {name = 'singularity_mark', rate = 15, limit = 0},
            -- {name = 'bloodletter_mark', rate = 10, limit = 0}
        }
    },
    desert = {
        normal = {
            -- {name = 'echo', rate = 12, limit = 0},
            {name = 'living_mark', rate = 5, limit = 0},
            {name = 'blink_mark', rate = 10, limit = 0},
            -- {name = 'singularity_mark', rate = 15, limit = 0},
            -- {name = 'bloodletter_mark', rate = 8, limit = 0}
        }
    },
    arena = {
        normal = {
            -- {name = 'echo', rate = 15, limit = 0},
            {name = 'living_mark', rate = 10, limit = 0},
            {name = 'blink_mark', rate = 5, limit = 0},
            -- {name = 'singularity_mark', rate = 8, limit = 0},
            -- {name = 'bloodletter_mark', rate = 12, limit = 0}
        }
    },
    plains = {
        normal = {
            -- {name = 'echo', rate = 10, limit = 0},
            {name = 'living_mark', rate = 15, limit = 0},
            {name = 'blink_mark', rate = 8, limit = 0},
            -- {name = 'singularity_mark', rate = 12, limit = 0},
            -- {name = 'bloodletter_mark', rate = 5, limit = 0}
        }
    },
    swamp = {
        normal = {
            -- {name = 'echo', rate = 5, limit = 0},
            {name = 'living_mark', rate = 12, limit = 0},
            {name = 'blink_mark', rate = 8, limit = 0},
            -- {name = 'singularity_mark', rate = 10, limit = 0},
            -- {name = 'bloodletter_mark', rate = 15, limit = 0}
        }
    },
    -- BOSS ROOMS
    dragon = {
        normal = {
            -- {name = 'echo', rate = 15, limit = 0},
            {name = 'living_mark', rate = 10, limit = 0},
            {name = 'blink_mark', rate = 12, limit = 0},
            -- {name = 'singularity_mark', rate = 8, limit = 0},
            -- {name = 'bloodletter_mark', rate = 5, limit = 0}
        }
    },
    phoenix = {
        normal = {
            -- {name = 'echo', rate = 8, limit = 0},
            {name = 'living_mark', rate = 15, limit = 0},
            {name = 'blink_mark', rate = 5, limit = 0},
            -- {name = 'singularity_mark', rate = 12, limit = 0},
            -- {name = 'bloodletter_mark', rate = 10, limit = 0}
        }
    },
    hydra = {
        normal = {
            -- {name = 'echo', rate = 10, limit = 0},
            {name = 'living_mark', rate = 5, limit = 0},
            {name = 'blink_mark', rate = 15, limit = 0},
            -- {name = 'singularity_mark', rate = 8, limit = 0},
            -- {name = 'bloodletter_mark', rate = 12, limit = 0}
        }
    }
}

return MatchMarks