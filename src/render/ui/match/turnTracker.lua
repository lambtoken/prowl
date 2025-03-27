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

return turnTracker