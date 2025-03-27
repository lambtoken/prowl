local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local fsm = require "libs.batteries.state_machine"
local SoundManager = require ("src.sound.SoundManager"):getInstance()
local SceneManager = require ("src.scene.SceneManager"):getInstance()
local music = require "src.sound.music"

local turnSystem = Concord.system({pool = {team}})


function turnSystem:init() 
    self.buffsDebuffSystem = gs.currentMatch.buffsDebuffSystem
    self.turn = 1
    -- self.states = fsm({
    --     playing = {
    --         instance = self,

    --         enter = function(s) 
    --         end,
            
    --         update = function(s, dt) 
    --         end,

    --         draw = function() 
    --         end,
            
    --         exit = function() 
    --         end
    --     },
    --     result = {
    --         instance = self,

    --         enter = function(s)
    --             s.sceneTimer = 0
    --             s.sceneTime = 0
    --             s.timerFlag = false
    --             if s.instance.winnerId == 1 then
    --                 SoundManager:playSound('victory')
    --             else
    --                 SoundManager:playSound('loss')
    --             end
    --         end,
            
    --         update = function(s, dt) 
    --             s.sceneTimer = s.sceneTimer + dt
                
    --             if s.sceneTimer >= s.sceneTime and s.timerFlag == false then
                                       
    --                 if s.instance.winnerId == 1 then
    --                     if math.random() > 0.5 then music.changeSong() end
    --                     SceneManager:switchScene("itemSelect")
    --                 else
    --                     gs.run:decreaseHealth()
    --                     if gs.run.runHealth > 0 then
    --                         SceneManager:switchScene("runMap")
    --                     else
    --                         gs.run:setOutcome()
    --                         SceneManager:switchScene("runEnd")
    --                     end
    --                 end
                    
    --                 s.timerFlag = true
    --             end

    --         end,

    --         draw = function(s) 
    --         end,
            
    --         exit = function() 
    --         end
    --     }
    -- }, "playing")

    -- self.states:set_state("playing")

    self.phase = fsm({
        stand_by_phase = {
            instance = self,

            -- onStandby event
            -- buffs/debuffs
            -- disabling, defensive
            -- dot
            -- passives

            -- phase starts on enter time of sliding text

            enter = function(s) 
                if false then
                    s.instance.phase:set_state("main_phase")
                end
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        main_phase = {
            instance = self,

            enter = function(s) 
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        },
        end_phase = {
            instance = self,

            enter = function(s) 
            end,
            
            update = function(s, dt) 
            end,

            draw = function() 
            end,
            
            exit = function() 
            end
        }
    }, "stand_by")

    self.phase:set_state("stand_by_phase")

end

function turnSystem:update(dt)
    for _, entity in ipairs(self.pool) do
    end
end

function turnSystem:handleStandBy()
    self.buffsDebuffSystem:onStandBy()
    -- disabling
    -- tags
    -- defensive
    -- dot
    -- onStandBy event
end


return turnSystem