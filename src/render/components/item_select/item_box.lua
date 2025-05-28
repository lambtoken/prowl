local portrait = require "src.render.components.portrait"
local gs = require("src.state.GameState"):getInstance()
local soundManager = require("src.sound.SoundManager"):getInstance()

local function item(item_name)
    
    local p = portrait(item_name)
    p.item_name = item_name

    p.onMousePressed = function(self)
        gs.run:giveItemAndProgress(self.item_name)
        soundManager:playSound("pdmg" .. tostring(math.random(1, 3)))
    end
    
    p.onMouseEntered = function(self)
        -- self:playAnimation("attack")
    end

    return p

end

return item