local renderManager = require ('src.render.RenderManager'):getInstance()

local min, max = 2, 6

local config = {
    nodeTypes = {'dungeon', 'arena', 'treasure', 'boss'},
    types = {'classic', 'forest', 'tundra', 'swamp', 'desert'},
    -- format = {1, 1, 3, 4, 2, 6, 3, 1},
    format = {1, 1, math.random(min, max), math.random(min, max), math.random(min, max), math.random(min, max), math.random(min, max), 1},

    nodeDistance = 30,
    colDistance = 60,
    nodeIconSize = 40,
    
}

config.increaseFactor = config.nodeIconSize / renderManager.spriteSize

return config