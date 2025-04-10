local transitions = require 'src.scene.transitions'
local renderManager = require ('src.render.RenderManager'):getInstance()
local mouse = require 'src.input.mouse'
local Cursor = require 'src.render.Cursor'
local cheatCodeListener = require 'src.input.cheatCodeListener'

local SceneManager = {}
SceneManager.__index = SceneManager
local instance = nil

function SceneManager:new()
    local o = {}
    setmetatable(o, self)
    self._index = self
    o:initialize()

    return o
end

function SceneManager:getInstance()
    if not instance then
        instance = SceneManager:new()
    end
    return instance
end

function SceneManager:initialize()
    self.scenes = {}
    self.subScenes = {}
    self.currentScene = nil
    self.previousScene = nil
    self.popSubsOnSceneChange = true
    self.transitionTimer = 0
    self.transitionType = 'fade'
    self.duration = 0.5
    self.mouseX = 0 -- unused?
    self.mouseY = 0
    self.globalKeyBindings = {}

    self.globalKeyBindings['`'] = function() love.event.quit('restart') end
end

function SceneManager:add(scene, name)
    assert(not self.scenes[name], "Scene with that name already added!")
    self.scenes[name] = scene
end

function SceneManager:load()
    self.cursor = Cursor:new()
    self.cursor:load()

    local files = love.filesystem.getDirectoryItems('src/scene/scenes')

    for _, file in ipairs(files) do
        local filepath = 'src/scene/scenes' .. "/" .. file
        
        if file:sub(-4) == ".lua" then
            local moduleName = filepath:sub(1, -5):gsub("/", ".")
            local sceneName = file:sub(1, -5)
            self.scenes[sceneName] = require(moduleName)
        end
    end
end

function SceneManager:draw()

    if self.currentScene then
        self.currentScene:draw()
        if self.currentScene.subScenes then
            for i, v in ipairs(self.currentScene.subScenes) do
                v:draw()
            end
        end
    end

    if self.transitionExit then
        transitions[self.transitionType].onExit.draw()
    end

    if self.transitionEnter then
        transitions[self.transitionType].onEnter.draw()
    end
    

    self.cursor:draw()
end

function SceneManager:update(dt)
    
    if self.currentScene then
        self.currentScene:update(dt)
        for i, v in ipairs(self.subScenes) do
            v:update(dt)
        end
    end

    if self.transitionExit then
        self.transitionTimer = self.transitionTimer + dt
        transitions[self.transitionType].onExit.update(dt)
        if self.transitionTimer >= transitions[self.transitionType].length then
            self.transitionExit = false
            self.transitionEnter = true
            self.transitionTimer = 0
            transitions[self.transitionType].onExit.exit()
            transitions[self.transitionType].onEnter.enter()
            self:changeScene()
        end
    end

    if self.transitionEnter then
        self.transitionTimer = self.transitionTimer + dt
        transitions[self.transitionType].onEnter.update(dt)
        if self.transitionTimer >= transitions[self.transitionType].length then
            self.transitionEnter = false
            self.transitionTimer = 0
        end
    end
    
    self.cursor:update(dt)
end

-- initiates scene change
function SceneManager:switchScene(sceneName, transitionType, duration)
    local transitionType = self.transitionType or 'fade'
    if self.transitionEnter then 
        self.transitionEnter = false 
        self.transitionTimer = 0 end
    self.nextScene = self.scenes[sceneName]
    self.transitionExit = true
    transitions[transitionType].length = duration or self.duration
    transitions[transitionType].onExit.enter()
end

-- actually changes the scene
function SceneManager:changeScene()
    if self.currentScene then
        self.currentScene:exit()
        self.previousScene = self.currentScene
    end
    self.currentScene = self.nextScene
    self.currentScene:enter()
end

function SceneManager:mousemoved(x, y, dx, dy)
    mouse.x = x
    mouse.y = y

    self.mouseX, self.mouseY = x, y

    if self.currentScene and self.currentScene.mousemoved then
        self.currentScene:mousemoved(x, y, dx, dy)
    end
end

function SceneManager:mousepressed(x, y, btn)
    if self.currentScene and self.currentScene.mousepressed then
        if not self.transitionExit then 
            self.currentScene:mousepressed(x, y, btn)
        end
    end

    self.cursor:mousepressed(x, y, btn)
end

function SceneManager:mousereleased(x, y, btn)
    if self.currentScene and self.currentScene.mousereleased then
        if not self.transitionExit then 
            self.currentScene:mousereleased(x, y, btn)
        end
    end

    self.cursor:mousereleased(x, y, btn)
end


function SceneManager:resize(w, h)
    if self.currentScene and self.currentScene.resize then
        self.currentScene:resize(w, h)
        renderManager.windowWidth = w
        renderManager.windowHeight = h
    end
end


function SceneManager:keypressed(key, scancode, isrepeat)

    cheatCodeListener.keypressed(key)

    if self.globalKeyBindings[key] then
        self.globalKeyBindings[key]()
    end

    if self.currentScene and self.currentScene.keypressed then
        if not self.transitionExit then 
            self.currentScene:keypressed(key, scancode, isrepeat)
        end
    end
end

return SceneManager