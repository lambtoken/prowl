local portrait = require "src.render.components.portrait"
local gs = require("src.state.GameState"):getInstance()

local function item(item_name)
    
    local p = portrait(item_name)
    p.item_name = item_name

    p.onMousePressed = function(self)
        gs.run:giveItemAndProgress(self.item_name)
    end
    
    p.onMouseEnter = function(self)
        self:playAnimation("attack")
    end

    return p

end

return item