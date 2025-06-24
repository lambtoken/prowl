local RM = require ('src.render.RenderManager'):getInstance()
-- local teamIcon = require 'src.render.ui.match.teamIcon'
local spriteTable = require 'src.render.spriteTable'

local turnTracker = {}
turnTracker.__index = turnTracker

function turnTracker:new() 
    local o = {
        animationTimer = 0,
        animationTime = 1,
        animationQuad = 0
    }
    setmetatable(o, self)
    o.__index = self

    return o
end

function turnTracker:load(teamManager)
    self.teamManager = teamManager
    self.textures = {
        teams = {},
        current0 = love.graphics.newQuad(spriteTable['team_current1'][1] * RM.spriteSize, spriteTable['team_current1'][2] * RM.spriteSize, 14, 14, RM.image),
        current1 = love.graphics.newQuad(spriteTable['team_current2'][1] * RM.spriteSize, spriteTable['team_current2'][2] * RM.spriteSize, 14, 14, RM.image),
        dead = love.graphics.newQuad(spriteTable['team_dead'][1] * RM.spriteSize, spriteTable['team_dead'][2] * RM.spriteSize, 14, 14, RM.image),
    }

    local i = 1

    for _, team in ipairs(self.teamManager.teams) do 
        local activeSprite = team.agentType .. i .. '_active'
        local inactiveSprite = team.agentType .. i .. '_inactive'
        table.insert(self.textures.teams, {
            activeQuad = love.graphics.newQuad(spriteTable[activeSprite][1] * RM.spriteSize, spriteTable[activeSprite][2] * RM.spriteSize, 14, 14, RM.image),
            inactiveQuad = love.graphics.newQuad(spriteTable[inactiveSprite][1] * RM.spriteSize, spriteTable[inactiveSprite][2] * RM.spriteSize, 14, 14, RM.image),
        })

        i = i + 1
    end

    self.screenX = RM.windowWidth - (14 * RM.increaseFactor * #self.teamManager.teams) 
    self.screenY = 0
    self.width = #self.teamManager.teams * 14 * RM.increaseFactor
    self.height = 14 * RM.increaseFactor
end

function turnTracker:draw()
    for i, team in ipairs(self.teamManager.teams) do
         
        local quad

        if self.teamManager.turnTeamId == i then
            quad = self.textures.teams[i].activeQuad
        else
            quad = self.textures.teams[i].inactiveQuad
        end
        
        love.graphics.draw(RM.image, quad, self.screenX + (14 * RM.increaseFactor * (i - 1)), 0, 0, RM.increaseFactor, RM.increaseFactor)

        if self.teamManager.turnTeamId == i then    
            love.graphics.draw(RM.image, self.textures['current' .. tostring(self.animationQuad)], self.screenX + (14 * RM.increaseFactor * (i - 1)), 0, 0, RM.increaseFactor, RM.increaseFactor)
        end
    
        if not team.alive then
            love.graphics.draw(RM.image, self.textures.dead, self.screenX + (14 * RM.increaseFactor * (i - 1)), 0, 0, RM.increaseFactor, RM.increaseFactor)
        end

        self:drawHealthBar(i, self.screenX + (14 * RM.increaseFactor * (i - 1)), self.screenY + 14 * RM.increaseFactor, 14 * RM.increaseFactor, 2 * RM.increaseFactor)
    end
end

function turnTracker:update(dt)
    self.animationTimer = self.animationTimer + dt
    if self.animationTimer >= self.animationTime then
        self.animationTimer = 0

        self.animationQuad = (self.animationQuad + 1) % 2
    end
end

function turnTracker:mousepressed(x, y, btn)
    if x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        return true
    end
    return false
end

function turnTracker:mousereleased(x, y, btn)
    if x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        return true
    end
    return false
end

function turnTracker:mousemoved(x, y)
    if x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        return true
    end
    return false
end

function turnTracker:getTeamMaxHealth(teamId)
    local team = self.teamManager.teams[teamId]
    if not team then return 0 end

    local maxHealth = 0
    for _, animal in ipairs(team.members) do
        maxHealth = maxHealth + animal.stats.current.maxHp
    end

    return maxHealth
end

function turnTracker:getTeamCurrentHealth(teamId)
    local team = self.teamManager.teams[teamId]
    if not team then return 0 end

    local currentHealth = 0
    for _, animal in ipairs(team.members) do
        currentHealth = currentHealth + animal.stats.current.hp
    end

    return currentHealth
end

function turnTracker:drawHealthBar(teamId, x, y, width, height)
    local team = self.teamManager.teams[teamId]
    if not team then return end

    local maxHealth = self:getTeamMaxHealth(teamId)
    local currentHealth = self:getTeamCurrentHealth(teamId)

    if maxHealth <= 0 then return end

    local healthPercentage = currentHealth / maxHealth
    local healthWidth = width * healthPercentage

    love.graphics.setColor(0, 1, 0) -- Green for health
    love.graphics.rectangle("fill", x, y, healthWidth, height)

    love.graphics.setColor(1, 1, 1) -- Reset color
end

return turnTracker