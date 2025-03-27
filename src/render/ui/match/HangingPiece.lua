local spriteTable = require "src.render.spriteTable"
local physics = love.physics
local RM = require ('src.render.RenderManager'):getInstance()
local mouse = require "src.input.mouse"

local HangingPiece = {}
HangingPiece.__index = HangingPiece

function HangingPiece:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function HangingPiece:load()
    self.world = physics.newWorld(0, 9.81 * 120, true)  -- Gravity: 9.81 m/s^2, converted to pixels

    self.squareBody = physics.newBody(self.world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, "dynamic")
    self.squareShape = physics.newRectangleShape(50, 50)
    self.fixture = physics.newFixture(self.squareBody, self.squareShape)
    self.squareBody:setAngularDamping(15)
    self.squareBody:setMass(3)
    self.squareBody:setFixedRotation(false)

    self.anchorBody = physics.newBody(self.world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 40, "static")

    self.distanceJoint = physics.newRevoluteJoint(self.squareBody, self.anchorBody, self.squareBody:getX(), self.squareBody:getY() + 40, false)
    self.squareBody:setSleepingAllowed(false)
end

function HangingPiece:setAnimalSprite(animal)
    self.quad = love.graphics.newQuad(spriteTable[animal][1] * RM.spriteSize, spriteTable[animal][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
end

function HangingPiece:resetAngularVelocity()
    self.squareBody:setAngularVelocity(0)
    self.squareBody:setAngle(math.pi)
end

function HangingPiece:draw()
    local squareX, squareY = self.squareBody:getPosition()

    -- Draw the sprite
    local angle = self.squareBody:getAngle()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(RM.image, self.quad, squareX, squareY, angle - math.pi, RM.increaseFactor, RM.increaseFactor, RM.spriteSize / 2, RM.spriteSize / 2)
end


function HangingPiece:update(dt)
    self.world:update(dt)
    self.anchorBody:setPosition(mouse.x, mouse.y)
end

return HangingPiece