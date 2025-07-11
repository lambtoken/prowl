local rates = {
    dungeon = {
        normal = {
            {name = 'cat', rate = 5, limit = 0},
            {name = 'chicken', rate = 10, limit = 0},
            {name = 'rat', rate = 10, limit = 0},
            {name = 'duck', rate = 10, limit = 0}
        },
        maze = {
            {name = 'spider', rate = 2, limit = 0},
            {name = 'bat', rate = 10, limit = 0},
            {name = 'rat', rate = 10, limit = 0},
            {name = 'duck', rate = 2, limit = 0},
            {name = 'crow', rate = 5, limit = 0}
        },
        plus = {
            {name = 'cat', rate = 1, limit = 0},
            {name = 'chicken', rate = 10, limit = 0},
            {name = 'rat', rate = 10, limit = 0},
            {name = 'duck', rate = 10, limit = 0},
            {name = 'crow', rate = 5, limit = 0},
            {name = 'rabbit', rate = 5, limit = 0}  
        }
    },
    forest = {
        normal = {
            {name = 'fox', rate = 1, limit = 0},
            {name = 'turtle', rate = 1, limit = 0},
            {name = 'bear', rate = 5, limit = 1},
            {name = 'deer', rate = 10, limit = 0},
            {name = 'crow', rate = 10, limit = 0},
            {name = 'rabbit', rate = 10, limit = 2}, 
            {name = 'hedgehog', rate = 10, limit = 2},  
            {name = 'fox', rate = 10, limit = 1},  
            {name = 'snake', rate = 10, limit = 1},  
        },
        dense = {
            {name = 'fox', rate = 5, limit = 0},
            {name = 'turtle', rate = 10, limit = 0},
            {name = 'bear', rate = 10, limit = 1},
            {name = 'deer', rate = 10, limit = 0},
            {name = 'crow', rate = 5, limit = 0},
            {name = 'rabbit', rate = 5, limit = 0}
        },
        gloam = {
            {name = 'owl', rate = 5, limit = 1},
            {name = 'crow', rate = 10, limit = 0},
            {name = 'bear', rate = 10, limit = 1},
            {name = 'deer', rate = 10, limit = 0},
            {name = 'rabbit', rate = 5, limit = 2}
        }
    },
    glacial = {
        normal = {
            {name = 'polar_bear', rate = 5, limit = 1},
            {name = 'deer', rate = 10, limit = 0},
            {name = 'rabbit', rate = 10, limit = 0},
            {name = 'penguin', rate = 10, limit = 3},
        },
        ice_spikes = {
            {name = 'polar_bear', rate = 10, limit = 1},
            {name = 'deer', rate = 10, limit = 0},
            {name = 'rabbit', rate = 10, limit = 0},
            {name = 'penguin', rate = 15, limit = 3},
        },
    },
    desert = {
        normal = {
            {name = 'rat', rate = 2, limit = 1},
            {name = 'camel', rate = 10, limit = 0},
            {name = 'rabbit', rate = 10, limit = 0}, 
            {name = 'rabbit', rate = 10, limit = 0} 
        },
    },
    arena = {
        normal = {
            {name = 'cat', rate = 1, limit = 0},
            {name = 'chicken', rate = 10, limit = 0},
            {name = 'bull', rate = 10, limit = 0},
            {name = 'duck', rate = 10, limit = 0},
            {name = 'crow', rate = 5, limit = 0},
            {name = 'crocodile', rate = 1, limit = 1} 
        } 
    },
    plains = {
        normal = {
            {name = 'cat', rate = 1, limit = 0},
            {name = 'chicken', rate = 10, limit = 0},
            {name = 'bull', rate = 15, limit = 0},
            {name = 'duck', rate = 10, limit = 0},
            {name = 'rabbit', rate = 10, limit = 0},
            {name = 'crow', rate = 5, limit = 0},
        } 
    },

    swamp = {
        normal = {
            {name = 'crocodile', rate = 10, limit = 1},
            {name = 'turtle', rate = 10, limit = 0},
            {name = 'frog', rate = 10, limit = 0},
            {name = 'poison_frog', rate = 5, limit = 0},
            {name = 'axolotl', rate = 10, limit = 0},
        }
    },

    beach = {
        normal = {
            {name = 'crab', rate = 10, limit = 0},
            {name = 'turtle', rate = 10, limit = 0},
            {name = 'seagull', rate = 10, limit = 0},
        }
    },

    savannah = {
        normal = {
            {name = 'lion', rate = 10, limit = 0},
            {name = 'zebra', rate = 10, limit = 0},
            {name = 'elephant', rate = 10, limit = 0},
            {name = 'giraffe', rate = 10, limit = 0},
        }
    },

    meadow = {
        normal = {
            {name = 'magpie', rate = 20, limit = 0},
            {name = 'ram', rate = 10, limit = 0},
            {name = 'deer', rate = 10, limit = 0},
            {name = 'rabbit', rate = 10, limit = 0},            
        }
    },

    cave = {
        normal = {
            {name = 'bat', rate = 20, limit = 0},
            {name = 'lizard', rate = 20, limit = 0},
            {name = 'snail', rate = 20, limit = 0},
            {name = 'spider', rate = 20, limit = 0},            
        }
    },


    -- BOSS ROOMS
    dragon = {
        normal = {
            {name = 'dragon', rate = 10000000, limit = 1},
            {name = 'snake', rate = 10, limit = 0},
            {name = 'bat', rate = 10, limit = 0},
        }
    },
    phoenix = {
        normal = {
            {name = 'phoenix', rate = 10000000, limit = 1},
            {name = 'chicken', rate = 10, limit = 0},
            {name = 'crow', rate = 10, limit = 0},
        },
    },
    hydra = {
        normal = {
            {name = 'hydra', rate = 10000000, limit = 1},
            {name = 'wolf', rate = 5, limit = 0},
            {name = 'crow', rate = 10, limit = 0},
        }
    }
}

return rates