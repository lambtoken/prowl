local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local fsm = require "libs.batteries.state_machine"
local SoundManager = require ("src.sound.SoundManager"):getInstance()
local SceneManager = require ("src.scene.SceneManager"):getInstance()
local music = require "src.sound.music"

local turnSystem = Concord.system({pool = {team}})


function turnSystem:init() 
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
    --                         SceneManager:switchScene("uiTest")
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

            -- go through all entities in the pool
            -- go through their passives and items
            -- if they have onStandBy event call it



            -- onStandby event
            -- buffs/debuffs
            -- disabling, defensive
            -- dot

            -- phase starts on enter time of sliding text

            enter = function(s)
                
                -- for index, entity in ipairs(s.instance.pool) do
                --     if entity.passive and entity.passive.onStandBy then
                --         entity.passive.onStandBy(gs.match, entity)
                --     end
                -- end
                
                -- -- Handle standby phase effects
                -- s.instance:handleStandBy()
            end,
            
            update = function(s, dt) 
                -- check for actions here.
                -- if no actions anymore switch to main_phase
                
                -- Check if all DoT effects are done before moving to main phase
                -- if gs.match and gs.damageOverTimeSystem:allDotEffectsDone() then
                --     s.instance.phase:set_state("main_phase")
                -- end
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
    -- gs.buffsDebuffSystem:onStandBy()
    -- gs.itemSystem:onStandBy()
    -- statusEffectSystem
    -- tags
    -- dot
    -- onStandBy event
end


return turnSystem