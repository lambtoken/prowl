local Scene = require 'src.scene.scene'
local getFont = require 'src.render.getFont'
local sceneM = require('src.scene.SceneManager'):getInstance()
local gs = require('src.state.GameState'):getInstance()
local mold = require "libs.mold"
local RM = require("src.render.RenderManager"):getInstance()

local test = "aaaaaaa"

local uiTest = Scene:new('uiTest')

function uiTest:enter()

    self.root = mold.Container:new():setRoot(RM.windowWidth, RM.windowHeight)
        :setAlignContent("center")
        :setJustifyContent("center")

    self.container = mold.Container:new()
        :setWidth("200px")
        :setHeight("200px")
        :setMode("squish")
        :setDirection("row")
        :debug()

    self.container.bgColor = {0.2, 0.3, 0.6}
    self.root:addChild(self.container)

    self.inner = mold.Container:new()
        :setWidth("100px")
        :setHeight("1000px")
        :setDirection("row")
        :debug()

    self.container:addChild(self.inner)

    self.text = mold.TextBox:new(test)
        :setColor({1, 1, 1, 1})
        :debug()

    self.text2 = mold.TextBox:new(test)
        :setColor({1, 1, 1, 1})
        :debug()
    
    self.inner:addChild(self.text)
    self.inner:addChild(self.text2)

    self.container:resize()    

    self.root:resize()

    -- self.root:printTree()
end

function uiTest:draw()
    self.root:draw()
end

function uiTest:update(dt)
    self.root:update(dt)
end

function uiTest:resize(w, h)
    self.root:setRoot(w, h)
    self.root:resize()
end

return uiTest