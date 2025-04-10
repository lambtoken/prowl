local Scene = require 'src.scene.scene'
local RM = require ('src.render.RenderManager'):getInstance()
local tween = require 'libs.tween'
local Item = require 'src.render.ui.ItemSelectItem'
local getRandomItems = require 'src.generation.functions.getRandomItems'
local pretty         = require 'libs.batteries.pretty'
local checkerShader = love.graphics.newShader(require('src.render.shaders.checker_shader'))
local SoundManager  = require('src.sound.SoundManager'):getInstance()
local mold = require "libs.mold"
local item_box = require "src.render.components.item_select.item_box"
local portrait = require "src.render.components.portrait"

local gs = require("src.state.GameState"):getInstance()

local itemMargin = 100
local itemSize = 200
local nItems = 3

local itemSelect = Scene:new('itemSelectNew')

function itemSelect:enter()
    self.root = mold.Container:new():setRoot(RM.windowWidth, RM.windowHeight)
        :setAlignContent("center")
        :setJustifyContent("center")

    self.item_container = mold.Container:new()
        :setWidth("70%")
        :setHeight("30%")
        :setJustifyContent("space-evenly")

    self.item_container.flexDirection = "row"

    self.root:addChild(self.item_container)

    self.items = {} 
    
    local generated_items = getRandomItems(math.random(1, 3), nItems)

    generated_items[1] = 'swiss_knife'
    -- randomItems[2] = 'racing_flag'
    -- randomItems[3] = 'mace'

    for _, i in ipairs(generated_items) do
        local item = item_box(i)
            :setWidth("20%")
            :setScaleBy("width")
        table.insert(self.items, item)
        self.item_container:addChild(item)
    end

    self.animal_container = mold.Container:new()
        :setWidth("70%")
        :setHeight("30%")
        :setJustifyContent("space-evenly")

    self.root:addChild(self.animal_container)

    self.current_animal = gs.run.team[1]

    self.animal_portrait = portrait(self.current_animal.metadata.species)
        :setWidth("20%")
        :setScaleBy("width")
        :playAnimation("sine_wave", true)

        
    -- self.animal_stats = stats(animal)
        
    self.animal_container:addChild(self.animal_portrait)
    -- self.animal_container:addChild(self.animal_stats)
    -- self.animal_container:addChild(self.animal_pattern)
    
    -- self:load_animal(self.current_animal)

    self.root:resize()

    SoundManager:playSound('clickyclicky')
end

function itemSelect:load_animal(animal)

end

function itemSelect:update(dt)
    checkerShader:send("time", love.timer.getTime())

    self.root:update(dt)
end

function itemSelect:draw()
    love.graphics.setShader(checkerShader)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, RM.windowWidth, RM.windowHeight)
    love.graphics.setShader()

    self.root:draw()
end

function itemSelect:mousemoved(x, y)
    self.root:mouseMoved(x, y)
end

function itemSelect:mousepressed(x, y, btn)
    self.root:mousePressed(x, y, btn)
end

function itemSelect:mousereleased(x, y, btn)
    self.root:mouseReleased(x, y, btn)
end

function itemSelect:resize(w, h)
    self.root:setRoot(w, h)
    self.root:resize()
end

return itemSelect

-- onClick adds those items to the players first animal in the team