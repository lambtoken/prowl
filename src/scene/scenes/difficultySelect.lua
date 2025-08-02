local Scene = require 'src.scene.scene'
local SceneManager = require('src.scene.SceneManager'):getInstance()
local soundM = require('src.sound.SoundManager'):getInstance()
local RM = require ('src.render.RenderManager'):getInstance()
local gs = require('src.state.GameState'):getInstance()
local mold = require('libs.mold')
local getFont = require 'src.render.getFont'

local difficultySelect = Scene:new('difficultySelect')

local root
local selectedDifficulty = nil

function difficultySelect:enter()
    -- Create root container
    root = mold.Container:new()
        :setRoot(RM.windowWidth, RM.windowHeight)
        :setJustifyContent("center")
        :setAlignContent("center")
        :setDirection("column")
        :setPadding("40px")

    root.bgColor = {0.1, 0.1, 0.1, 0.9}

    -- Title
    local title = root:addChild(mold.TextBox:new("Select Difficulty"))
        :setSize(48)
        :setColor({1, 1, 1, 1})
        :setMargin("40px", "bottom")

    -- Subtitle
    local subtitle = root:addChild(mold.TextBox:new("Choose your AI opponent strength"))
        :setSize(24)
        :setColor({0.8, 0.8, 0.8, 1})
        :setMargin("20px", "bottom")

    -- Difficulty buttons container
    local buttonsContainer = root:addContainer()
        :setWidth("600px")
        :setHeight("auto")
        :setDirection("column")
        :setJustifyContent("center")
        :setAlignContent("center")
        :setMargin("40px", "top")

    -- Easy difficulty
    local easyContainer = buttonsContainer:addContainer()
        :setWidth("100%")
        :setHeight("auto")
        :setDirection("column")
        :setMargin("15px", "bottom")
        :setPadding("20px")
        :setJustifyContent("center")
        :setAlignContent("center")

    easyContainer.bgColor = {0.2, 0.4, 0.2, 0.8}

    local easyButton = easyContainer:addChild(mold.Button("EASY"))
        :setTextMargin("15px")
    

    local easyDesc = easyContainer:addChild(mold.TextBox:new("AI makes random moves frequently.\nGreat for learning the game."))
        :setSize(18)
        :setColor({0.9, 0.9, 0.9, 1})
        :setMargin("10px", "top")

    function easyButton.onMouseReleased()
        gs.settings.difficulty = "easy"
        selectedDifficulty = "easy"
        SceneManager:switchScene('animalSelect')
        soundM:playSound('clicktech2')
    end

    -- Medium difficulty
    local mediumContainer = buttonsContainer:addContainer()
        :setWidth("100%")
        :setHeight("auto")
        :setDirection("column")
        :setMargin("15px", "bottom")
        :setPadding("20px")
        :setJustifyContent("center")
        :setAlignContent("center")

    mediumContainer.bgColor = {0.4, 0.3, 0.2, 0.8}

    local mediumButton = mediumContainer:addChild(mold.Button("MEDIUM"))
        :setTextMargin("15px")
    

    local mediumDesc = mediumContainer:addChild(mold.TextBox:new("AI makes mostly good moves.\nBalanced challenge for most players."))
        :setSize(18)
        :setColor({0.9, 0.9, 0.9, 1})
        :setMargin("10px", "top")


    function mediumButton.onMouseReleased()
        gs.settings.difficulty = "medium"
        selectedDifficulty = "medium"
        SceneManager:switchScene('animalSelect')
        soundM:playSound('clicktech2')
    end

    -- Hard difficulty
    local hardContainer = buttonsContainer:addContainer()
        :setWidth("100%")
        :setHeight("auto")
        :setDirection("column")
        :setMargin("15px", "bottom")
        :setPadding("20px")
        :setJustifyContent("center")
        :setAlignContent("center")

    hardContainer.bgColor = {0.4, 0.2, 0.2, 0.8}

    local hardButton = hardContainer:addChild(mold.Button("HARD"))
        :setTextMargin("15px")
    

    local hardDesc = hardContainer:addChild(mold.TextBox:new("AI plays optimally most of the time.\nFor experienced players seeking a challenge."))
        :setSize(18)
        :setColor({0.9, 0.9, 0.9, 1})
        :setMargin("10px", "top")

    function hardButton.onMouseReleased()
        gs.settings.difficulty = "hard"
        selectedDifficulty = "hard"
        SceneManager:switchScene('animalSelect')
        soundM:playSound('clicktech2')
    end

    -- Back button
    local backButton = root:addChild(mold.Button("Back"))
        :setTextMargin("12px")
        :setMargin("40px", "top")

    function backButton.onMouseReleased()
        SceneManager:switchScene('mainMenu')
        soundM:playSound('click1')
    end

    -- Set current difficulty as default
    selectedDifficulty = gs.settings.difficulty or "medium"

    root:resize()
end

function difficultySelect:update(dt)
    if root then
        root:update(dt)
    end
end

function difficultySelect:draw()
    love.graphics.clear(51/255, 77/255, 51/255, 1)
    
    if root then
        root:draw()
    end
end

function difficultySelect:mousemoved(x, y, dx, dy)
    if root then
        root:mouseMoved(x, y, dx, dy)
    end
end

function difficultySelect:mousepressed(x, y, btn)
    if root then
        root:mousePressed(x, y, btn)
    end
end

function difficultySelect:mousereleased(x, y, btn)
    if root then
        root:mouseReleased(x, y, btn)
    end
end

function difficultySelect:keypressed(key)
    if key == 'escape' then
        SceneManager:switchScene('mainMenu')
        soundM:playSound('click1')
    elseif key == '1' then
        gs.settings.difficulty = "easy"
        SceneManager:switchScene('animalSelect')
        soundM:playSound('clicktech2')
    elseif key == '2' then
        gs.settings.difficulty = "medium"
        SceneManager:switchScene('animalSelect')
        soundM:playSound('clicktech2')
    elseif key == '3' then
        gs.settings.difficulty = "hard"
        SceneManager:switchScene('animalSelect')
        soundM:playSound('clicktech2')
    end
end

function difficultySelect:exit()
    root = nil
end

return difficultySelect 