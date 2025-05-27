local Scene = require 'src.scene.scene'
local SceneManager = require('src.scene.SceneManager'):getInstance()
local RM = require ('src.render.RenderManager'):getInstance()
local gs = require('src.state.GameState'):getInstance()
local mold = require('libs.mold')
local spriteTable = require('src.render.spriteTable')
local tween = require('libs.tween')

local animalBg = {}

function animalBg:load()
    self.size = RM.tileSize * 2
    self.increase = RM.increaseFactor * 2
    self.amp = 20
    self.time = 0
    self.animals = {}
    
    local x = math.ceil(RM.windowWidth / RM.tileSize)
    local y = math.ceil(RM.windowHeight / RM.tileSize)

    local animalTopLeft = {0, 0}
    local animalBotRight = {17, 1}

    local itemTopLeft = {0, 4}
    local itemBotRight = {40, 7}

    local index = 1

    for i = 0, x do
        for j = 0, y do
            local randAnimalX
            local randAnimalY
            if math.random() > 0.5 then
                randAnimalX = animalTopLeft[1] + math.random(animalBotRight[1] - animalTopLeft[1])
                randAnimalY = animalTopLeft[2] + math.random(animalBotRight[2] - animalTopLeft[2])
            else
                randAnimalX = itemTopLeft[1] + math.random(itemBotRight[1] - itemTopLeft[1])
                randAnimalY = itemTopLeft[2] + math.random(itemBotRight[2] - itemTopLeft[2])
            end

            local offsetX = math.sin(self.time + index) * self.amp
            local offsetY = math.cos(self.time + index) * self.amp
        
            local quad = love.graphics.newQuad(randAnimalX * RM.spriteSize, randAnimalY * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
            
            local ax = i * self.size
            local ay = j * self.size
            table.insert(self.animals, {x = ax, y = ay, offsetX = offsetX, offsetY = offsetY, quad = quad})
            index = index + 1
        end
    end
end

function animalBg:draw()

    -- RM:pushShader("gray")

    love.graphics.clear(193/255, 224/255, 201/255, 1)
    for _, a in ipairs(self.animals) do
        -- -0.1 + math.random() % 0.2
        love.graphics.push()
        love.graphics.translate(a.x + a.offsetX, a.y + a.offsetY)
        love.graphics.draw(RM.image, a.quad, - self.size/2, - self.size/2, 0, self.increase)
        love.graphics.pop()
    end

    -- RM:popShader()

end

function animalBg:update(dt)
    self.time = self.time + dt  -- Accumulate time

    for index, a in ipairs(self.animals) do
        a.offsetX = math.sin(self.time + index) * self.amp
        a.offsetY = math.cos(self.time + index) * self.amp
    end
end

local mainMenu = Scene:new('mainMenu')

local root
local logo

function mainMenu:enter()

    root = mold.Container:new()
        :setRoot(RM.windowWidth, RM.windowHeight)
        :setJustifyContent("space-evenly")
        :setAlignContent("center")
        :setPadding("16px")

    root.bgColor = nil

    logo = root:addChild(mold.ImageBox:new("assets/logo.png"))
        :setScaleBy("width")
        :setWidth("500px")
        :setPosition("relative")

    self.logoSwing = 0
    self.logoTween = tween.new(2, self, {logoSwing = 1}, "inOutQuad")
   
    local buttons = root:addContainer()
        :setWidth("auto")
        :setHeight("auto")
        :setJustifyContent("space-evenly")
        :setAlignContent("center")

    buttons.bgColor = nil

    local new_game_btn = buttons:addChild(mold.Button("New Game"))
        :setTextMargin("20px")
        :setMargin("15px", "bottom")

    function new_game_btn.onMouseReleased()
        SceneManager:switchScene('animalSelect')
    end

    local options_btn = buttons:addChild(mold.Button("Options"))
        :setTextMargin("20px")
        :setMargin("15px", "bottom")
    options_btn.disabled = true

    local exit_btn = buttons:addChild(mold.Button("Exit"))
        :setTextMargin("20px")

    for index, child in ipairs(buttons.children) do
        -- child.bgColor = {0.2, 0.2, 0.2, 0.8}
        child.bgColor = {0.7, 0.7, 0.7, 0.9}
        -- child.textBox.color = {1, 1, 1, 1}
        child:setWidth("512px")
        -- child:setHeight(60)
        child:setTextMargin("0px")
        child.textBox:setSize(50)
    end


    local socials = root:addContainer():setWidth("auto"):setHeight("auto")
    socials.flexDirection = "row"
    socials.bgColor = nil

    local steamSprite = spriteTable.steam

    local steam = socials:addChild(mold.QuadBox:new(
        RM.image, 
        steamSprite[1] * RM.spriteSize, 
        steamSprite[2] * RM.spriteSize, 
        12, 
        12
    )):setPosition("static"):setWidth(12 * 4):setHeight(12 * 4)

    local redditSprite = spriteTable.reddit

    local reddit = socials:addChild(mold.QuadBox:new(
        RM.image, 
        redditSprite[1] * RM.spriteSize, 
        redditSprite[2] * RM.spriteSize, 
        12, 
        12
    )):setPosition("static"):setWidth(12 * 4):setHeight(12 * 4)

    reddit.onMousePressed = function(self, x, y, click)
        love.system.openURL("https://www.reddit.com/r/prowl")
    end

    for index, child in ipairs(socials.children) do
        child.onMouseEnter = function(self)
            self:playAnimation("attack")
        end
        
        if index ~= #socials.children then
            child:setMargin("10px", "right")
        end
    end

    -- version
    local ver = root:addChild(mold.TextBox:new("v0.0.7"))
        :setPosition("fixed")
        :setMargin("auto", "top")
        :setSize(50)

    root:resize()

    animalBg:load()
end


function mainMenu:update(dt)

    if self.logoTween:update(dt) then
        if self.logoSwing == 1 then
            self.logoTween = tween.new(2, self, {logoSwing = 0}, "inOutQuad")
        else
            self.logoTween = tween.new(2, self, {logoSwing = 1}, "inOutQuad")
        end
    end

    local dist = 20

    logo:setPos(0, -dist / 2 + self.logoSwing * dist)
    logo.parent:resize()

    animalBg:update(dt)
    root:update(dt)
end

function mainMenu:draw()
    animalBg:draw()

    if root then
        root:draw()
    end
end

function mainMenu:mousemoved(x, y)
    root:mouseMoved(x, y)
end

function mainMenu:mousepressed(x, y, click)
    root:mousePressed(x, y, click)
end

function mainMenu:mousereleased(x, y, click)
    root:mouseReleased(x, y, click)
end

function mainMenu:wheelmoved(x, y)
    root:wheelMoved(x, y)
end

function mainMenu:keypressed(k)
    root:keyPressed(k)
end

function mainMenu:resize(w, h)
    -- root:setRoot(RM.windowWidth, RM.windowHeight)
    -- root:resize()
end

return mainMenu