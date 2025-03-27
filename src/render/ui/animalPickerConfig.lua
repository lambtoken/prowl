local RM = require ('src.render.RenderManager'):getInstance()
local data = require 'src.data'

local config = {
    cols = 6,
    animalIconSize = RM.tileSize,
    iconPadding = 5,
    iconMargin = 100
}

config.animalIconScaleFactor = config.animalIconSize / RM.spriteSize
config.rows = math.ceil(data.animalCount / config.cols)
config.width = config.cols * config.animalIconSize
config.height = config.rows * config.animalIconSize
config.screenX = math.floor((RM.windowWidth / 2) - (config.width + (config.cols * config.iconPadding) * 2) / 2)
config.screenY = math.floor((RM.windowHeight / 2) - (config.height + (config.rows * config.iconPadding) * 2) / 2)
config.frameSize = config.animalIconSize + config.iconPadding * 2


return config