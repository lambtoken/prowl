local RM = require ('src.render.RenderManager'):getInstance()
local spriteTable = require "src.render.spriteTable"

local particles = {}

local LG = love.graphics

--HIT
particles.hit = function()
    local quad = LG.newQuad(spriteTable['hit'][1] * RM.spriteSize, spriteTable['hit'][2] * RM.spriteSize, 3, 3, RM.image)
    local quad1 = LG.newQuad(spriteTable['hit'][1] * RM.spriteSize + 3, spriteTable['hit'][2] * RM.spriteSize, 3, 3, RM.image)
    local quad2 = LG.newQuad(spriteTable['hit'][1] * RM.spriteSize + 3, spriteTable['hit'][2] * RM.spriteSize + 3, 3, 3, RM.image)
    local quad3 = LG.newQuad(spriteTable['hit'][1] * RM.spriteSize, spriteTable['hit'][2] * RM.spriteSize + 3, 3, 3, RM.image)
    local ps = LG.newParticleSystem(RM.image, 30)
    ps:setQuads(quad, quad1, quad2, quad3)
    ps:setColors(0.55078125, 0.55078125, 0.55078125, 0.55078125)
    ps:setDirection(1.550390958786)
    ps:setEmissionArea("uniform", 12.888281822205, 17.54238319397, 1.6396528482437, false)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(2.6848933696747, 8.6990547180176, 2.6848933696747, 5.2623910903931)
    ps:setLinearDamping(5.1610202789307, 9.7910566329956)
    ps:setParticleLifetime(0.44160908460617, 1.0981433391571)
    ps:setRadialAcceleration(2191.0876464844, 4768.5854492188)
    ps:setRelativeRotation(false)
    ps:setRotation(0, 0)
    ps:setSizes(1 * RM.increaseFactor)
    ps:setSizeVariation(0)
    ps:setSpeed(510.38748168945, 1058.87890625)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(3.8895909786224)
    ps:setTangentialAcceleration(1.9331232309341, -1.9331232309341)

    return {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=5, blendMode="add", shader=nil, texturePath="circle.png", texturePreset="circle", shaderPath="", shaderFilename="", x=4.0816326530612, y=0}
end

--BLEED
particles.bleed = function()
    local ps = LG.newParticleSystem(RM.image, 7)
    ps:setColors(1, 0, 0, 0.79296875)
    ps:setDirection(1.5707963705063)
    ps:setEmissionArea("uniform", 0, 73.477951049805, 1.5707963705063, false)
    ps:setEmissionRate(3.8098583221436)
    ps:setEmitterLifetime(9.3438339233398)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(1.9837824106216, 6.4274554252625, 1.9837824106216, 3.888213634491)
    ps:setLinearDamping(-0.0051036551594734, 0.0051036551594734)
    ps:setOffset(50, 50)
    ps:setParticleLifetime(1.5366493463516, 1.4125283956528)
    ps:setRadialAcceleration(3.9675648212433, 1.4283233880997)
    ps:setRelativeRotation(false)
    ps:setRotation(0, 0)
    ps:setSizes(0.48408827185631)
    ps:setSizeVariation(0)
    ps:setSpeed(7.1416168212891, 103.12494659424)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(0)
    ps:setTangentialAcceleration(1.4283233880997, -1.4283233880997)
    return {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="swirl.png", texturePreset="swirl", shaderPath="", shaderFilename="", x=-6.8027210884354, y=0}
end

particles.step = function()
    local ps = LG.newParticleSystem(RM.image, 7)
    ps:setColors(0.625, 0.625, 0.625, 0.2265625, 1, 1, 1, 1, 1, 1, 1, 0.5, 0.16015625, 0.16015625, 0.16015625, 0.453125)
    ps:setDirection(-1.4801363945007)
    ps:setEmissionArea("none", 0, 0, 0, false)
    ps:setEmissionRate(111.11804199219)
    ps:setEmitterLifetime(0.060069907456636)
    ps:setInsertMode("random")
    ps:setLinearAcceleration(-0.22706788778305, -0.22706788778305, 0.22706788778305, -2.0436110496521)
    ps:setLinearDamping(-0.00050185556756333, -0.024590920656919)
    ps:setOffset(50, 10.5)
    ps:setParticleLifetime(0.27211585640907, 0.49134981632233)
    ps:setRadialAcceleration(-4.0872220993042, 0.4541357755661)
    ps:setRelativeRotation(false)
    ps:setRotation(0, 6.2831854820251)
    ps:setSizes(0.3288848400116)
    ps:setSizeVariation(0.96166133880615)
    ps:setSpeed(162.88439941406, 180.98266601563)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0.43450480699539)
    ps:setSpread(6.2831854820251)
    ps:setTangentialAcceleration(4.0872220993042, 11.353394508362)
    return {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="", texturePreset="ellipse", shaderPath="", shaderFilename="", x=0, y=0}
end

particles.goldStars = function()
    local ps = LG.newParticleSystem(RM.image, 47)
    ps:setColors(1, 0.72052001953125, 0.05859375, 0, 0.96231079101563, 1, 0.62890625, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
    ps:setDirection(-1.5707963705063)
    ps:setEmissionArea("uniform", 304.89602661133, 314.57467651367, 0, false)
    ps:setEmissionRate(20)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(0, 0, 0, 0)
    ps:setLinearDamping(-2.6998336315155, -1.8424195051193)
    ps:setOffset(50, 50)
    ps:setParticleLifetime(1.7999999523163, 2.2000000476837)
    ps:setRadialAcceleration(0, -3723.7290039063)
    ps:setRelativeRotation(false)
    ps:setRotation(0, 0)
    ps:setSizes(0.82745009660721)
    ps:setSizeVariation(0)
    ps:setSpeed(-1543.8557128906, 1166.103515625)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(0.31415927410126)
    ps:setTangentialAcceleration(0, 0)
    return {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="star.png", texturePreset="star", shaderPath="", shaderFilename="", x=0, y=0}
end


particles.sleep = function()
    local ps = LG.newParticleSystem(RM.image, 8)
    ps:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
    ps:setDirection(-1.5707963705063)
    ps:setEmissionArea("none", 0, 0, 0, false)
    ps:setEmissionRate(0.75256460905075)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(0, 0, 0, 0)
    ps:setLinearDamping(0, 0)
    ps:setOffset(50, 50)
    ps:setParticleLifetime(1.9761352539063, 2.3911237716675)
    ps:setRadialAcceleration(-0.074069507420063, -0.074069507420063)
    ps:setRelativeRotation(true)
    ps:setRotation(-0.85196632146835, 0.89605540037155)
    ps:setSizes(0.29448255896568)
    ps:setSizeVariation(0)
    ps:setSpeed(65.308639526367, 72.565155029297)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    ps:setSpread(1.1668772697449)
    ps:setTangentialAcceleration(3.6294059753418, 46.293441772461)
    return {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="moon.png", texturePreset="moon", shaderPath="", shaderFilename="", x=0, y=0}
end


particles.heal = function()
    local quad = LG.newQuad(spriteTable['heal'][1] * RM.spriteSize, spriteTable['heal'][2] * RM.spriteSize, 3, 3, RM.image)
    local ps = LG.newParticleSystem(RM.image, 30)
    ps:setQuads(quad)    
    ps:setColors(
        1, 1, 1, 0, 
        1, 1, 1, 1, 
        1, 1, 1, 0.5, 
        1, 1, 1, 0
    )
    ps:setDirection(-1.5707963705063)
    ps:setEmissionArea("normal", RM.tileSize / 2, RM.tileSize / 2, 0, false)
    -- ps:setEmissionRate(30)
    ps:setEmitterLifetime(-1)
    ps:setInsertMode("top")
    ps:setLinearAcceleration(0, 0, 0, 0)
    ps:setLinearDamping(0, 1)
    ps:setParticleLifetime(1.9761352539063, 5)
    ps:setRadialAcceleration(-0.074069507420063, -0.074069507420063)
    ps:setRelativeRotation(true)
    ps:setRotation(-0.85196632146835, 0.89605540037155)
    ps:setSizes(1 * RM.increaseFactor)
    ps:setSizeVariation(0)
    ps:setSpeed(65.308639526367, 72.565155029297)
    ps:setSpin(0, 0)
    ps:setSpinVariation(0)
    -- ps:setSpread(1.1668772697449)
    ps:setTangentialAcceleration(3.6294059753418, 46.293441772461)
    return {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=0, blendMode="add", shader=nil, texturePath="moon.png", texturePreset="moon", shaderPath="", shaderFilename="", x=0, y=0}
end

-- particles.heal = function()
--     local quad = LG.newQuad(spriteTable['heal'][1] * RM.spriteSize, spriteTable['heal'][2] * RM.spriteSize, 3, 3, RM.image)
--     local ps = LG.newParticleSystem(RM.image, 30)
--     ps:setQuads(quad)
--     ps:setColors(0.55078125, 0.55078125, 0.55078125, 0.55078125)
--     ps:setDirection(1.550390958786)
--     ps:setEmissionArea("uniform", 12.888281822205, 17.54238319397, 1.6396528482437, false)
--     -- ps:setEmitterLifetime(0.030510477721691)
--     ps:setEmitterLifetime(-1)
--     ps:setInsertMode("top")
--     ps:setLinearAcceleration(2.6848933696747, 8.6990547180176, 2.6848933696747, 5.2623910903931)
--     ps:setLinearDamping(5.1610202789307, 9.7910566329956)
--     ps:setParticleLifetime(0.44160908460617, 1.0981433391571)
--     ps:setRadialAcceleration(2191.0876464844, 4768.5854492188)
--     ps:setRelativeRotation(false)
--     ps:setRotation(0, 0)
--     ps:setSizes(1 * RM.increaseFactor)
--     ps:setSizeVariation(0)
--     ps:setSpeed(510.38748168945, 1058.87890625)
--     ps:setSpin(0, 0)
--     ps:setSpinVariation(0)
--     ps:setSpread(3.8895909786224)
--     ps:setTangentialAcceleration(1.9331232309341, -1.9331232309341)

--     return {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=5, blendMode="add", shader=nil, texturePath="circle.png", texturePreset="circle", shaderPath="", shaderFilename="", x=4.0816326530612, y=0}
-- end

return particles