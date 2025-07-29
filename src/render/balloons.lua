local RM = require("src.render.RenderManager"):getInstance()
local spriteTable = require "src.render.spriteTable"

local LG        = love.graphics
local particles = {x = RM.windowWidth / 2, y = RM.windowHeight / 2}

balloonSprite = 'balloon'
local quad = LG.newQuad(spriteTable[balloonSprite][1] * RM.spriteSize, spriteTable[balloonSprite][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)

local ps = LG.newParticleSystem(RM.image, 16)
ps:setQuads(quad)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("uniform", RM.windowWidth / 2, 100, 0, false)
ps:setEmitterLifetime(-1)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, -150, 0, -150)
ps:setLinearDamping(0.01, 0.01)
ps:setParticleLifetime(4)
ps:setRadialAcceleration(-0.074069507420063, -0.074069507420063)
ps:setRelativeRotation(false)
ps:setRotation(-0.85196632146835, 0.89605540037155)
ps:setSizes(12)
ps:setSizeVariation(0)
ps:setSpeed(114.84568023682, 127.6063079834)
ps:setSpread(3.2313523292542)
ps:setTangentialAcceleration(3.6294059753418, 46.293441772461)
ps:setColors(
    1, 1, 1, 0,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 0
)

return ps