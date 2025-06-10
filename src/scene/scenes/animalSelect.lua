local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local Run = require 'src.run.Run'
local sceneM = require('src.scene.SceneManager'):getInstance()
local gs = require('src.state.GameState'):getInstance()
local animalPickerConfig = require 'src.render.ui.animalPickerConfig'
local spriteTable = require 'src.render.spriteTable'
local RM = require ('src.render.RenderManager'):getInstance()
local data = require 'src.data'
local mobs = require 'src.generation.mobs'
local pretty = require 'libs.batteries.pretty'
local mold = require 'libs.mold'
local SoundManager = require ('src.sound.SoundManager'):getInstance()
local animal_details = require 'src.render.components.animal_details'

local animalSelect = Scene:new('animalSelect')

function animalSelect:enter()

    self.root = mold.Container:new()
        :setRoot(RM.windowWidth, RM.windowHeight)
        :setJustifyContent("space-evenly")
        :setAlignContent("center")

    self.roster = animalSelect:makeRoster()

    -- local rows = math.ceil(data.animalCount / animalPickerConfig.cols)
    local cols = animalPickerConfig.cols

    local container = self.root:addContainer()
        :setWidth("auto")
        :setHeight("auto")

    container.bgColor = {0.8, 0.8, 0.8, 1}
        
    local function newRow()
        local row = mold.Container:new()
            :setWidth("auto")
            :setHeight("auto")

        row.flexDirection = "row"

        return row
    end

    container:addChild(newRow())

    while #self.roster > 0 do
        local a = table.remove(self.roster, 1)
        
        local lastRow = container.children[#container.children]

        if #lastRow.children > cols then
            container:addChild(newRow())
        end
        
        container.children[#container.children]:addChild(a)
    end

    self.details = nil

    self.detailsBySpecies = {}

    for _, animal in ipairs(data.animals) do
        local species = animal.key
        self.detailsBySpecies[species] = animal_details(mobs[species])
    end

    self.root:resize()
end

function animalSelect:update(dt)
    self.root:update(dt)
end

function animalSelect:mousemoved(x, y)
    if self.details then
        self.details:setPos(x, y)
    end
    self.root:mouseMoved(x, y)
end

function animalSelect:mousepressed(x, y, button)
    self.root:mousePressed(x, y, button)
    
function animalSelect:mousereleased(x, y, button)
    self.root:mouseReleased(x, y, button)
end

function animalSelect:pick(species)
    if not gs.run then

        local newRun = Run:new(species)
            newRun:setSeed(gs.rng:get("general", 1, 2^53))
            gs:setRun(newRun)
        end

        sceneM:switchScene('runMap')
    end
end

function animalSelect:draw()
    love.graphics.setColor(1, 1, 1 ,1)
    self.root:draw()
end

function animalSelect:makeRoster()

    local arr = {}

    local randomSprite = spriteTable.question_mark
    local r = mold.QuadBox:new(
        RM.image, 
        randomSprite[1] * RM.spriteSize, 
        randomSprite[2] * RM.spriteSize, 
        RM.spriteSize,
        RM.spriteSize
    )
    :setWidth("100px")
    :setHeight("100px")

    r.onMouseEnter = function(self)
        SoundManager:playSound("softclick2")
        self:playAnimation("attack")
    end

    r.onMouseReleased = function(s)
        local random = data.animals[math.ceil(math.random() * #data.animals)].key
        self:pick(random)
    end
    
    table.insert(arr, r)

    for i, animal in ipairs(data.animals) do

        local animalSprite = spriteTable[animal.key]
        local anim = mold.QuadBox:new(
            RM.image,
            animalSprite[1] * RM.spriteSize,
            animalSprite[2] * RM.spriteSize,
            RM.spriteSize,
            RM.spriteSize
        )
        :setWidth("100px")
        :setHeight("100px")

        anim.species = animal.key

        anim.onMouseEnter = function(s)
            -- SoundManager:playSound("softclick2")
            s:playAnimation("attack")
            -- SoundManager:playSound("pclick3")
            SoundManager:playSound("clicktech2")
            self.details = self.detailsBySpecies[anim.species]
            self.details:setPos(50, 120) -- hack. i dont like it. need to fix mold
            self.root:addChild(self.details)
            self.root:resize()
        end
        
        anim.onMouseExited = function(s)
            self.root:removeChild(self.details)
            if self.details then
                self.root:removeChild(self.details)
                self.details = nil
                self.root:resize()
            end
        end
        
        anim.onMouseReleased = function(s)
            self:pick(s.species)
            SoundManager:playSound("pclick4")
            if self.details then
                self.root:removeChild(self.details)
                self.details = nil
                self.root:resize()
            end
        end

        table.insert(arr, anim)
        -- data.getAnimal(data.animals[i].key)
    end
    
    return arr
end

function animalSelect:keypressed(key)
    if key == 'escape' then
        SoundManager:playSound("pm3")
        sceneM:switchScene('mainMenu')
    end
end

return animalSelect