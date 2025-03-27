local spriteTable = require "src.render.spriteTable"

local config = {}

config.spriteSize = 16
config.windowWidth, config.windowHeight = love.graphics.getDimensions()
config.tileSize = math.ceil(config.windowHeight / 10 / 16) * 16
config.resX, config.resY = math.ceil(config.windowWidth / config.tileSize), math.ceil(config.windowHeight / config.tileSize)
config.renderDistanceX = math.floor(config.windowWidth / config.tileSize) + 3
config.renderDistanceY = math.floor(config.windowHeight / config.tileSize) + 3
config.increaseFactor = config.tileSize / config.spriteSize

config.font = nil

config.spritesPath = '/assets/sprites.png'
config.logoPath = '/assets/logo.png'
config.logoScale = 0.4
love.graphics.setDefaultFilter("nearest", "nearest")
config.image = love.graphics.newImage(config.spritesPath)
config.imageData = love.image.newImageData(config.spritesPath)
config.teamColors = {}

for i = 1, 5 do

    local spriteName = 'bot' .. i .. '_active'

    local r, g, b = config.imageData:getPixel(spriteTable[spriteName][1] * config.spriteSize, spriteTable[spriteName][2] * config.spriteSize)     
    
    table.insert(config.teamColors, {r, g, b})

end

config.logoImage = love.graphics.newImage(config.logoPath)


config.xoffset = 0
config.yoffset = 0
config.shakeDuration = 0.3
config.shakeTimer = 0
config.isShaking = false
config.shakeMagnitude = 4

config.hudHotbarX = 0
config.hudHotbarY = config.windowHeight - 60

config.buttonTextSize = 2

return config
