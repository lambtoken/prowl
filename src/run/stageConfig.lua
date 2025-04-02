local renderManager = require ('src.render.RenderManager'):getInstance()

local config = {
    nodeTypes = {'dungeon', 'arena', 'treasure', 'boss'},
    types = {'classic', 'forest', 'tundra', 'swamp', 'desert'},
    format = {1, 1, 3, 4, 2, 6, 3, 1},

    nodeDistance = 30,
    colDistance = 60,
    nodeIconSize = 40,
    
}

config.increaseFactor = config.nodeIconSize / renderManager.spriteSize

return config