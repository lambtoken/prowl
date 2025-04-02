local spriteTable = require "src.render.spriteTable"

-- Add effect sprites to the sprite table
spriteTable.poison_effect = {0, 24}  -- You'll need to adjust these coordinates to match your sprite sheet
spriteTable.stun_effect = {1, 24}
spriteTable.burn_effect = {2, 24}
spriteTable.freeze_effect = {3, 24}
spriteTable.bleed_effect = {4, 24}
spriteTable.default_effect = {5, 24}  -- Default effect icon

return spriteTable 