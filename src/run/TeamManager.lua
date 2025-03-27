local Team = require 'src.run.Team'
local fsm = require 'libs.batteries.state_machine'
local EventManager = require('src.state.events'):getInstance()

local teamManager = {}
teamManager.__index = teamManager

function teamManager:new(currentMatch) 
    local o = {
        currentMatch = currentMatch
    }
    setmetatable(o, self)
    o.__index = self
    
    o.teams = {}
    o.maxTeams = 5
    o.turnTeamId = 1
    o.busy = false
    o.timer = nil
    o.time = 0.02
    o.lastActiveMob = nil
    o.states = fsm({
        start_phase = {
            instance = o,

            enter = function(s) 
                s.instance.states:set_state('main_phase')
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

            enter = function() 
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        main_phase = {
            instance = o,

            enter = function(s)
                s.instance.busy = false
            end,
            
            update = function(s, dt)
                -- run while systems are doing their stuff
                if s.instance.busy then
                    -- start the timer when everything is idle
                    if s.instance.timer == nil and s.instance.currentMatch:areAllMobsIdle() then
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
                    -- skip if team is empty or has no moves
                    if #s.instance.teams[s.instance.turnTeamId].members == 0 or 
                    s.instance.lastActiveMob and not s.instance.currentMatch:hasMovesLeft(s.instance.lastActiveMob) then
                        s.instance.states:set_state("end_phase")
                    else
                        -- handling bots
                        if s.instance.teams[s.instance.turnTeamId].agentType == "bot" then
                            local move = s.instance.currentMatch.aiManager:getMove(s.instance.turnTeamId)
                            if move then
                                s.instance.currentMatch.moveSystem:move(move.entity, "walk", move.x, move.y, true)
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

                local team = s.instance.teams[s.instance.turnTeamId]

                if not team.rest then
                    team.restCounter = team.restCounter + 1
                    if team.restCounter > 1 then
                        team.rest = true
                        team.restCounter = 0
                    end
                end

                s.instance.states:set_state("start_phase")
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
    
    o.states:set_state("start_phase")
    return o
end

function teamManager:load()
    EventManager = require('src.state.events'):getInstance()
    EventManager:on("checkTeamStatus", function(teamID)
        for index, member in ipairs(self.teams[teamID].members) do
            if member.state.current == "alive" then
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
    animal.metadata.teamID = id
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

function teamManager:draw()
end

return teamManager