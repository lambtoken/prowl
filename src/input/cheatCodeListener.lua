local cheatCodes = require 'src.input.cheatCodes'
local pretty     = require 'libs.batteries.pretty'

local listener = {}
local pressed = {}

listener.keypressed = function(key)

    if #pressed > 15 then
        table.remove(pressed, #pressed)
    end

    table.insert(pressed, 1, key)

    pretty.print(pressed)
    
    for i, cheat in ipairs(cheatCodes) do

        for j = 1, #cheat.code do
            if string.sub(cheat.code, #cheat.code - j + 1, #cheat.code - j + 1) ~= pressed[j] then
                goto continue
            end
        end
        
        cheat.callback()
        pressed = {}

        ::continue::
    end
end

return listener