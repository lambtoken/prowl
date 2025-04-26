local GameState = require'src.state.GameState'
local SceneManager = require'src.scene.SceneManager'
local RenderManager = require'src.render.RenderManager'
local music = require 'src.sound.music'
local getFont = require 'src.render.getFont'

-- _._     _,-'""`-._
-- (,-.`._,'(       |\`-/|
--     `-.-' \ )-`( , o o)
--           `-    \`_`"'-

local function wrapFunction(module, funcName)
    local oldFunc = module[funcName]
    module[funcName] = function(...)

        return oldFunc(...)
    end
end

-- Wrap multiple drawing functions
local drawFunctions = {
    "draw",
    "rectangle",
    "circle",
    "line",
    "polygon",
    "print",
    "printf",
}

for _, funcName in ipairs(drawFunctions) do
    wrapFunction(love.graphics, funcName)
end

local gs = nil
local sceneM = nil
local shaderM = nil
local renderM

function love.load(args)

    for index, value in ipairs(args) do
        if value == "test" then
            print("TESTING")
            love.event.quit(0)
        end
    end

    gs = GameState:getInstance()
    gs:setSeed(os.time())
    
    sceneM = SceneManager:getInstance()
    sceneM:load()
    sceneM:switchScene('loading')

    renderM = RenderManager:getInstance()

    --soundM = SoundManager:getInstance()
    music.load()

    require "src.render.effectSprites"

    love.window.setVSync(-1)
end

local fpsCap = 60
local frameDuration = 1 / fpsCap

function love.update(dt)
    -- dt = dt * 10
    if not gs.isPaused then
        require("libs/lovebird").update()
        sceneM:update(dt)
    end

    renderM:update(dt)

    music.update(dt)

    local sleepTime = frameDuration - dt
    if sleepTime > 0 then
        love.timer.sleep(sleepTime)  -- Sleep to cap FPS
    end
end

function love.draw()
    sceneM:draw()
    renderM:draw()
    -- love.graphics.setFont(getFont('basis33', 30))
    -- love.graphics.print(love.timer.getFPS(), 0, 0)
end

function love.mousemoved(x, y)
    sceneM:mousemoved(x, y)
end


function love.mousepressed(x, y, btn)
    sceneM:mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
    sceneM:mousereleased(x, y, btn)
end

function love.resize(w, h)
    sceneM:resize(w, h)
end

function love.keypressed(key, scancode, isrepeat)
    sceneM:keypressed(key, scancode, isrepeat)
end

