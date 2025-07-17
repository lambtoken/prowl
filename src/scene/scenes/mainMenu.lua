local Scene = require 'src.scene.scene'
local SceneManager = require('src.scene.SceneManager'):getInstance()
local soundM = require('src.sound.SoundManager'):getInstance()
local RM = require ('src.render.RenderManager'):getInstance()
local gs = require('src.state.GameState'):getInstance()
local mold = require('libs.mold')
local spriteTable = require('src.render.spriteTable')
local tween = require('libs.tween')
local mobData = require('src.generation.mobs')
local itemData = require('src.generation.items')

local animalBg = {}

function animalBg:load()
    self.size = RM.tileSize * 2
    self.increase = RM.increaseFactor * 2
    self.amp = 20
    self.time = 0
    self.animals = {}
    
    local mobSprites = {}
    for mobName, mobInfo in pairs(mobData) do
        if mobInfo.sprite and spriteTable[mobInfo.sprite] then
            table.insert(mobSprites, mobInfo.sprite)
        end
    end
    
    local itemSprites = {}
    for itemName, itemInfo in pairs(itemData) do
        if itemInfo.name and spriteTable[itemInfo.name] then
            table.insert(itemSprites, itemInfo.name)
        end
    end
    
    local x = math.ceil(RM.windowWidth / RM.tileSize)
    local y = math.ceil(RM.windowHeight / RM.tileSize) * 2

    local index = 1

    for i = 0, x do
        for j = 0, y do
            local spriteName
            
            if math.random() > 0.5 and #mobSprites > 0 then
                spriteName = mobSprites[math.random(#mobSprites)]
            elseif #itemSprites > 0 then
                spriteName = itemSprites[math.random(#itemSprites)]
            else
                goto continue
            end

            local offsetX = math.sin(self.time + index) * self.amp
            local offsetY = math.cos(self.time + index) * self.amp
            
            local spriteCoords = spriteTable[spriteName]
            if spriteCoords then
                local quad = love.graphics.newQuad(
                    spriteCoords[1] * RM.spriteSize, 
                    spriteCoords[2] * RM.spriteSize, 
                    RM.spriteSize, 
                    RM.spriteSize, 
                    RM.image
                )
                
                local ax = i * self.size
                local ay = j * self.size
                table.insert(self.animals, {x = ax, y = ay, offsetX = offsetX, offsetY = offsetY, quad = quad})
            end
            
            index = index + 1
            ::continue::
        end
    end
end

function animalBg:draw()

    love.graphics.clear(193/255, 224/255, 201/255, 1)
    for _, a in ipairs(self.animals) do
        RM:pushScreen()
        love.graphics.scale(RM.scale)
        local x = a.x + a.offsetX
        local y = a.y + a.offsetY
        love.graphics.translate(x, y)
        love.graphics.draw(RM.image, a.quad, - self.size/2, - self.size/2, 0, self.increase)
        love.graphics.pop()
    end

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
        soundM:playSound('clicktech2')
    end

    local options_btn = buttons:addChild(mold.Button("Options"))
        :setTextMargin("20px")
        :setMargin("15px", "bottom")
    options_btn.disabled = true

    local exit_btn = buttons:addChild(mold.Button("Exit"))
        :setTextMargin("20px")

    function exit_btn.onMouseReleased()
        love.event.quit()
    end

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