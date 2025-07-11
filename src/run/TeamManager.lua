local Team = require 'src.run.Team'
local fsm = require 'libs.batteries.state_machine'
local mobs = require 'src.generation.mobs'
local EventManager = require('src.state.events'):getInstance()
local pretty = require 'libs.batteries.pretty'

local teamManager = {}
teamManager.__index = teamManager

function teamManager:new(currentMatch) 
    local o = {
        match = currentMatch
    }
    setmetatable(o, self)
    o.__index = self
    
    o.teams = {}
    o.maxTeams = 5
    o.turnTeamId = 1
    o.busy = false
    o.timer = nil
    o.time = 0.02
    o.moveQueue = {}
    o.lastActiveMob = nil
    o.states = fsm({
        start_phase = {
            instance = o,

            enter = function(s) 
                s.instance.states:set_state('stand_by_phase')
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        stand_by_phase = {
            instance = o,

            enter = function(s) 

                EventManager:emit("standByPhase", s.instance.turnTeamId)

                s.instance.match.statusEffectSystem:onStandBy(s.instance.turnTeamId)
                s.instance.match.statusEffectSystem:applyAllStatusEffects()
                s.instance.match.damageOverTimeSystem:onStandBy(s.instance.turnTeamId)
                s.instance.match.buffDebuffSystem:onStandBy(s.instance.turnTeamId)
                
                local team = s.instance.teams[s.instance.turnTeamId]

                for _, animal in ipairs(team.members) do
                    if animal.metadata.teamId == s.instance.turnTeamId then
                        local animalData = mobs[animal.metadata.species]
                        if animalData and animalData.passive and animalData.passive.onStandBy then
                            animalData.passive.onStandBy(s.instance.match, animal)
                        end
                    end
                end

                s.instance.match.itemSystem:onStandBy(s.instance.turnTeamId)

                s.instance.match.statsSystem:calculateStats()

                if s.instance.match:areAllMobsIdle() then
                    s.instance.states:set_state('main_phase')
                else
                    s.instance.dotCheckTimer = 0
                end
            end,
            
            update = function(s, dt) 
                -- Check if DoT effects are complete before moving to main phase
                if s.instance.dotCheckTimer then
                    s.instance.dotCheckTimer = s.instance.dotCheckTimer + dt
                    
                    -- Check every 100ms
                    if s.instance.dotCheckTimer >= 0.1 then
                        s.instance.dotCheckTimer = 0
                        
                        if s.instance.match:areAllMobsIdle() then
                            s.instance.dotCheckTimer = nil
                            s.instance.states:set_state('main_phase')
                        end
                    end
                end
            end,

            draw = function() 
            end,
            
            exit = function(s) 
                s.instance.dotCheckTimer = nil
            end
        },
        main_phase = {
            instance = o,

            enter = function(s)
                if s.instance.teams[s.instance.turnTeamId].agentType == "bot" then
                    local currentTeam = s.instance.teams[s.instance.turnTeamId]
                    local amount = math.ceil(#currentTeam.members / 3)
                    s.instance.moveQueue = s.instance.match.aiManager:getMoves(s.instance.turnTeamId, amount)
                end
                s.instance.busy = false
            end,
            
            update = function(s, dt)
                -- run while systems are doing their stuff
                if s.instance.busy then
                    -- start the timer when everything is idle
                    if s.instance.timer == nil and s.instance.match:areAllMobsIdle() then
                        s.instance.timer = 0
                    end

                    if s.instance.timer then
                        s.instance.timer = s.instance.timer + dt

                        if s.instance.timer >= s.instance.time then
                            s.instance.busy = false
                            s.instance.timer = nil
                        end
                    end

                else
                    -- skip if team is empty or has no moveso
                    local currentTeam = s.instance.teams[s.instance.turnTeamId]
                    if #currentTeam.members == 0 or 
                    not s.instance:teamHasActions() and
                    #s.instance.moveQueue == 0 and
                    s.instance.lastActiveMob and not s.instance.match:hasMovesLeft(s.instance.lastActiveMob) then
                        s.instance.states:set_state("end_phase")
                    else
                        -- handling bots
                        if s.instance.teams[s.instance.turnTeamId].agentType == "bot" then
                            print(#s.instance.moveQueue)
                            local move = table.remove(s.instance.moveQueue)
                            if move then
                                s.instance.match.moveSystem:move(move.entity, "walk", move.x, move.y, true)
                                s.instance:setLastActiveMob(move.entity)
                                s.instance.busy = true
                            else
                                s.instance.states:set_state("end_phase")
                            end
                        end
                    end
                end
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        end_phase = {
            instance = o,

            enter = function(s) 

                EventManager:emit("endPhase", s.instance.turnTeamId)

                local team = s.instance.teams[s.instance.turnTeamId]

                for _, animal in ipairs(team.members) do
                    if animal.metadata.teamId == s.instance.turnTeamId then
                        if animal.passive and animal.passive.onEndTurn then
                            animal.passive.onEndTurn(s.instance.match, animal)
                        end
                    end

                    for _, item in ipairs(animal.inventory.items) do
                        if item.passive and item.passive.onEndTurn then
                            item.passive.onEndTurn(s.instance.match, animal, item)
                        end
                    end
                end

                if not team.rest then
                    team.restCounter = team.restCounter + 1
                    if team.restCounter > 1 then
                        team.rest = true
                        team.restCounter = 0
                        -- Replenish energy for all animals on this team
                        for _, animal in ipairs(team.members) do
                            if animal.stats and animal.stats.energy then
                                animal.stats.energy = animal.stats.maxEnergy or animal.stats.energy
                            end
                        end
                    end
                end

                s.instance.states:set_state("stand_by_phase")
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function(s)
                s.instance:nextAliveTeam()
                s.instance.lastActiveMob = nil
            end
        }
    ,'start_phase'})
    
    return o
end

function teamManager:load()
    EventManager = require('src.state.events'):getInstance()
    EventManager:on("checkTeamStatus", function(teamID)
        for index, member in ipairs(self.teams[teamID].members) do
            if member.state.alive then
                return
            end
        end

        self.teams[teamID]:setAliveState(false)
    end)    
end

function teamManager:newTeam(agentType)
    assert(#self.teams < self.maxTeams, "Exceeded number of teams.")

    table.insert(self.teams, Team:new(agentType or "bot"))
end

function teamManager:addToTeam(id, animal)
    animal.metadata.teamId = id
    table.insert(self.teams[id].members, animal)
end

function teamManager:setLastActiveMob(mob)
    self.lastActiveMob = mob
    self.busy = true
end

function teamManager:update(dt)
    self.states:update(dt)
end

function teamManager:nextTeam()
    self.turnTeamId = (self.turnTeamId % #self.teams) + 1

    for _, team in ipairs(self.teams) do
        for _, animal in ipairs(team.members) do
            animal.state.currentTurnMoves = 0
        end 
    end
end

function teamManager:nextAliveTeam()
    for i = 1, #self.teams do
        local teamId = ((self.turnTeamId + i - 1) % #self.teams) + 1
        if self.teams[teamId].alive then
            self.turnTeamId = teamId
            break
        end
    end

    for _, team in ipairs(self.teams) do
        for _, animal in ipairs(team.members) do
            animal.state.currentTurnMoves = 0
        end 
    end
end

function teamManager:canCurrentTeamRest()
    return self.teams[self.turnTeamId].rest
end

function teamManager:teamHasActions()
    local actions = false
    for index, animal in ipairs(self.teams[self.turnTeamId]) do
        actions = actions or self.match.stateSystem.hasActions(animal)
    end    
    return actions
end

function teamManager:draw()
end

return teamManager