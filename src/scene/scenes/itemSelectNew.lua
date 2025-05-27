local Scene = require 'src.scene.scene'
local RM = require ('src.render.RenderManager'):getInstance()
local soundManager = require("src.sound.SoundManager"):getInstance()
local GS = require ('src.state.GameState'):getInstance()
local Item = require 'src.render.ui.ItemSelectItem'
local getRandomItems = require 'src.generation.functions.getRandomItems'
local checkerShader = love.graphics.newShader(require('src.render.shaders.checker_shader'))
local SoundManager  = require('src.sound.SoundManager'):getInstance()
local mold = require "libs.mold"
local item_box = require "src.render.components.item_select.item_box"
local portrait = require "src.render.components.portrait"
local stats = require "src.render.components.stats"
local move_atk_pattern = require "src.render.components.move_atk_pattern"
local item_details = require "src.render.components.item_details"

local gs = require("src.state.GameState"):getInstance()

local itemMargin = 100
local itemSize = 200
local nItems = 3

local itemSelect = Scene:new('itemSelectNew')

function itemSelect:enter()
    self.root = mold.Container:new():setRoot(RM.windowWidth, RM.windowHeight)
        :setAlignContent("center")
        :setJustifyContent("center")

    self.title = self.root:addChild(mold.TextBox:new("Choose an item!"))
    self.title:setSize(70)
        :setColor({1,1,1,1})
        :playAnimation("bubble_up", true)

    self.item_container = mold.Container:new()
        :setWidth("70%")
        :setHeight("auto")
        :setJustifyContent("space-evenly")
        -- :debug()

    self.item_container.flexDirection = "row"

    self.root:addChild(self.item_container)

    self.items = {} 
    self.hoverItemId = nil
    
    local generated_items = getRandomItems(math.random(1, 3), nItems) -- just names

    -- generated_items[1] = 'mixer'

    self.test = item_details(generated_items[1])
    print(generated_items[1])
    -- racing flag

    for _, i in ipairs(generated_items) do
        local item = item_box(i)
            :setWidth("20%")
            :setScaleBy("width")
            -- :debug()

        item.onMouseEnter = function(s)
            s:playAnimation("attack")
            SoundManager:playSound("pclick5")
            -- soundManager:playSound("ppop")
            self:previewItem(i)
            self.root:addChild(self.test)
        end

        item.onMouseExited = function(s)
            self:removeItem()
            self.root:removeChild(self.test)
        end

        table.insert(self.items, item)
        self.item_container:addChild(item)
    end

    self.current_animal = gs.run.team[1]

    -- team 1 (player), animal 1 (usually starter animal)
    self:change_animal(1)
    self:load_animal()

    self.root:resize()
    SoundManager:playSound('clickyclicky')
end

function itemSelect:buildUI(change_portrait)    
    if not self.current_animal then
        return
    end
    
    self.root:removeChild(self.animal_container)
    self.root:removeChild(self.animal_stats)
    
    self.animal_atk_pattern = nil
    self.animal_move_pattern = nil
    self.animal_stats = nil

    self.animal_container = mold.Container:new()
        :setWidth("70%")
        :setHeight("30%")
        :setJustifyContent("space-evenly")
        :setAlignContent("center")
        :setDirection("row")
        -- :debug()
        
    self.root:addChild(self.animal_container)
        
    self.animal_stats = stats(self.current_animal)
    self.animal_move_pattern = move_atk_pattern(self.current_animal.stats.currentPatterns.movePattern, "move")
    -- self.animal_move_pattern:playAnimation("sine_wave", true)
    self.animal_atk_pattern = move_atk_pattern(self.current_animal.stats.currentPatterns.atkPattern, "atk")
    self.root:addChild(self.animal_stats)
    self.animal_container:addChild(self.animal_move_pattern)
    self.animal_container:addChild(self.animal_atk_pattern)
    
    if change_portrait then
        self.animal_portrait = portrait(self.current_animal.metadata.species)
            :setWidth("20%")
            :setScaleBy("width")
            :playAnimation("sine_wave", true)
            -- :debug()
        self.animal_container:addChild(self.animal_portrait)
    end

    self.root:resize()
end

function itemSelect:load_animal(animal)
    self:buildUI(true)
end

-- todo: member picker on the side

function itemSelect:change_animal(id)
    self.current_animal = gs.run.team[id]
end

function itemSelect:previewItem(item_name)
    -- equip item
    self.hoverItemId = gs.match.itemSystem:giveItem(self.current_animal, item_name).id

    -- recalc
    gs.match.statsSystem:calculateAnimalStats(self.current_animal)

    -- rerender
    self:buildUI(true)
end

function itemSelect:removeItem()
    print(self.hoverItemId)
    gs.match.itemSystem:unequipItemById(self.current_animal, self.hoverItemId)
    gs.match.statsSystem:calculateAnimalStats(self.current_animal)
    self:buildUI(true)
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

function itemSelect:exit()
    if self.hoverItemId then
        gs.match.itemSystem:unequipItemById(self.current_animal, self.hoverItemId)
    end
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
    -- self.root:setRoot(w, h)
    -- self.root:resize()
end

return itemSelect

-- onClick adds those items to the players first animal in the team