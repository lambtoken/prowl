local spriteTable = require "src.render.spriteTable"
local shaders = require "src.render.shaders.shaders"

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
    self.tileSize = 96
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
    self.tempCanvas = love.graphics.newCanvas()
    
    -- Track current canvas state
    self.currentCanvas = nil
    
    -- shaders
    self.shaderStack = {}
    self:createShaders()

    --transform
    self.transformStack = { love.math.newTransform() }
    
    -- camera shake
    self.xoffset = 0
    self.yoffset = 0
    self.shakeDuration = 0.3
    self.shakeTimer = 0
    self.isShaking = false
    self.shakeMagnitude = 10

    self.renderDistanceX = 16
    self.renderDistanceY = 16

    self.virtualWidth = 1280
    self.virtualHeight = 720
    self.scale = 1
    self.offsetX = 0
    self.offsetY = 0
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

function RenderManager:resize(w, h)
    self.virtualWidth = w
    self.virtualHeight = h
    self.scale = math.min(self.virtualWidth / self.windowWidth, self.virtualHeight / self.windowHeight)
    self.offsetX = math.floor((self.virtualWidth - self.windowWidth * self.scale) / 2)
    self.offsetY = math.floor((self.virtualHeight - self.windowHeight * self.scale) / 2)

    -- self.tileSize = math.floor(self.windowHeight / 10 / 16) * 16
end

function RenderManager:pushVirtual()
    love.graphics.push()
    love.graphics.translate(self.offsetX, self.offsetY)
    love.graphics.scale(self.scale)
end

function RenderManager:pushScreen()
    love.graphics.push()
    love.graphics.origin()
end

function RenderManager:mouseToVirtual(x, y)
    return (x - self.offsetX) / self.scale, (y - self.offsetY) / self.scale
end

function RenderManager:createShaders()
    for name, shader in pairs(shaders) do
        shader.shader = love.graphics.newShader(shader.code)
    end
end

function RenderManager:sendDefaultUniforms(shader, name)
    for _, uniform in ipairs(shaders[name].uniforms) do
        shader:send(uniform.name, uniform.default)
    end
end

function RenderManager:sendUniform(name, value)
    self.shaderStack[#self.shaderStack]:send(name, value)
end

function RenderManager:pushShader(name)
    local newShader = shaders[name].shader
    assert(newShader, "Shader does not exist!")
    self:sendDefaultUniforms(newShader, name)
    table.insert(self.shaderStack, newShader)
    love.graphics.setShader(newShader)
end

function RenderManager:popShader(num)
    if not num or num == 1 then
        table.remove(self.shaderStack)
    else
        -- this might be slow
        for i = 1, num do
            table.remove(self.shaderStack)
        end
    end

    self:setShader()
end

function RenderManager:sendUniforms(uniforms)
    for _, uniform in ipairs(uniforms) do
        self.shaderStack[#self.shaderStack]:send(uniform.name, uniform.value)
    end
end

function RenderManager:setCanvas(canvas)
    if self.currentCanvas ~= canvas then
        love.graphics.setCanvas(canvas)
        self.currentCanvas = canvas
    end
end

function RenderManager:resetCanvas()
    if self.currentCanvas then
        love.graphics.setCanvas()
        self.currentCanvas = nil
    end
end

function RenderManager:pushTransform()
    table.insert(self.transformStack, love.math.newTransform())
end

function RenderManager:popTransform()
    local transform = table.remove(self.transformStack)
    return transform
end

function RenderManager:cloneTransform()
    local top = self.transformStack[#self.transformStack]
    self.transformStack[#self.transformStack + 1] = top:clone()
end

function RenderManager:translate(x, y)
    self.transformStack[#self.transformStack]:translate(x, y)
end

function RenderManager:scale(sx, sy)
    self.transformStack[#self.transformStack]:scale(sx, sy)
end

function RenderManager:rotate(angle)
    self.transformStack[#self.transformStack]:rotate(angle)
end

function RenderManager:applyTransform()
    love.graphics.origin()
    if #self.transformStack > 0 then
        love.graphics.applyTransform(self.transformStack[#self.transformStack])
    end
end

function RenderManager:draw()
    love.graphics.setShader()
        
    -- self:setCanvas(self.bgCanvas)
    -- love.graphics.clear(0, 0, 0, 0)

    -- drawing to to main canvas
    -- self:setCanvas(self.mainCanvas)
    -- love.graphics.setColor(1, 1, 1, 1)
    
    -- should also implement a second canvas for applying additional processing
    -- it would probably eat some frames but would be worth it

    -- how this would work:

    -- at any time in the drawing pipeline you can draw to temp and apply shaders there
    -- then you can redraw results to main

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.mainCanvas, 0, 0)
end

function RenderManager:setShader()
    if #self.shaderStack == 0 then
        love.graphics.setShader()
    else
        love.graphics.setShader(self.shaderStack[#self.shaderStack])
    end
end

function RenderManager:switchToTemp()
    self:setCanvas(self.tempCanvas)
    love.graphics.clear(0, 0, 0, 0)  -- Clear with transparent
end

function RenderManager:switchToBg()
    self:setCanvas(self.bgCanvas)
end

-- function RenderManager:flushToMain()
--     self:setCanvas(self.mainCanvas)
--     love.graphics.setColor(1, 1, 1, 1)
--     love.graphics.draw(self.bgCanvas, 0, 0)
--     self:resetCanvas()
--     self:setShader()
-- end

return RenderManager