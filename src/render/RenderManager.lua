local spriteTable = require "src.render.spriteTable"
-- import all shaders

local gray = love.graphics.newShader(require "src.render.shaders.gray_shader")


local RenderManager = {}
RenderManager.__index = RenderManager

function RenderManager:new() 
    local o = {}
   
    setmetatable(o, self)
    o.__index = self

    o:init()

    return o
end

local instance

function RenderManager:init()
    -- window scaling config
    self:updateWindowSize()
    self.spriteSize = 16
    self.tileSize = 96 -- backup lol
    -- ui scale
    self.increaseFactor = self.tileSize / self.spriteSize

    -- images and colors
    self.spritesPath = '/assets/sprites.png'
    self.logoPath = '/assets/logo.png'
    love.graphics.setDefaultFilter("nearest", "nearest")
    self.image = love.graphics.newImage(self.spritesPath)
    self.imageData = love.image.newImageData(self.spritesPath)
    self.teamColors = self:extractTeamColors()
    self.mainCanvas = love.graphics.newCanvas()
    self.bgCanvas = love.graphics.newCanvas()

    -- shaders
    self.shaderStack = {}

    -- camera shake
    self.xoffset = 0
    self.yoffset = 0
    self.shakeDuration = 0.3
    self.shakeTimer = 0
    self.isShaking = false
    self.shakeMagnitude = 4

    self.renderDistanceX = 16
    self.renderDistanceY = 16
end

function RenderManager:getInstance()
    if not instance then
        instance = self:new()
    end

    return instance
end

function RenderManager:updateWindowSize()
    self.windowWidth, self.windowHeight = love.graphics.getDimensions()
end

function RenderManager:extractTeamColors()
    local colors = {}
    for i = 1, 5 do
        local spriteName = 'bot' .. i .. '_active'
        local r, g, b = self.imageData:getPixel(spriteTable[spriteName][1] * self.spriteSize, spriteTable[spriteName][2] * self.spriteSize)     
        table.insert(colors, {r, g, b})
    end
    return colors
end

function RenderManager:update(dt) end

function RenderManager:applyShake()
    love.graphics.translate(self.xoffset, self.yoffset)
end

function RenderManager:resize()
    self:updateWindowSize()

    self.tileSize = math.floor(self.windowHeight / 10 / 16) * 16
end

function RenderManager:pushShader(shdr)
    table.insert(self.shaderStack, gray)
end

function RenderManager:popShader()
    return table.remove(self.shaderStack)
end

function RenderManager:switchToBg()
    love.graphics.setCanvas(self.bgCanvas)
    love.graphics.clear(1, 1, 1, 1)
end

function RenderManager:flushToMain()
    love.graphics.setCanvas(self.mainCanvas)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.bgCanvas, 0, 0)
end

function RenderManager:applyShaders()

    if #self.shaderStack > 0 then
        for index, shader in ipairs(self.shaderStack) do
            love.graphics.setShader(shader)
        end
    else
        love.graphics.setShader()
    end

end

return RenderManager