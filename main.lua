local GameState = require'src.state.GameState'
local SceneManager = require'src.scene.SceneManager'
local RenderManager = require'src.render.RenderManager'
local music = require 'src.sound.music'
local getFont = require 'src.render.getFont'
local push = require 'libs.push'

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

local virtualWidth, virtualHeight = 1280, 720 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth*.7, windowHeight*.7 --make the window a bit smaller than the screen itself
local letterboxing = windowWidth - virtualHeight

local gs = nil
local sceneM = nil
local shaderM = nil
local renderM

function love.load()
    push:setupScreen(virtualWidth, virtualHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    
    gs = GameState:getInstance()
    gs:setSeed(os.time())
    
    sceneM = SceneManager:getInstance()
    sceneM:load()
    sceneM:switchScene('loading')

    renderM = RenderManager:getInstance()

    --soundM = SoundManager:getInstance()
    music.load()

    -- Require the effect sprites to ensure they're loaded
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

    push:start()

    sceneM:draw()
    renderM:draw()

    push:finish()
    -- love.graphics.setFont(getFont('basis33', 30))
    -- love.graphics.print(love.timer.getFPS(), 0, 0)
end

function love.mousemoved(x, y)
    local vx, vy = push:toGame(x, y)
    if vx and vy then
        x = math.max(0, math.min(vx, virtualWidth))
        y = math.max(0, math.min(vy, virtualHeight))
        x, y = vx, vy
        print(x, y)
    end

    sceneM:mousemoved(x, y)
end


function love.mousepressed(x, y, btn)
    local vx, vy = push:toGame(x, y)
    if vx and vy then
        x = math.max(0, math.min(vx, virtualWidth))
        y = math.max(0, math.min(vy, virtualHeight))
    end

    sceneM:mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
    local vx, vy = push:toGame(x, y)
    if vx and vy then
        x = math.max(0, math.min(vx, virtualWidth))
        y = math.max(0, math.min(vy, virtualHeight))
    end

    sceneM:mousereleased(x, y, btn)
end

function love.resize(w, h)
    --sceneM:resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key, scancode, isrepeat)
    sceneM:keypressed(key, scancode, isrepeat)
end

