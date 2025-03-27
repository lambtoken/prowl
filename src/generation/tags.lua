local isInTable = require "src.utility.isInTable"

local marks = {
    -- paintbrush
    paint = {
        duration = 3,
        onApply = function(matchState, source, target)
            if not isInTable(source.marks, target) then
                matchState.combatSystem:dealDamage(target, 1)
            end
        end
    },
    -- harpoon
    fish = {
        duration = nil,
        onProc = function(matchState, source, target)
            matchState.combatSystem:dealDamage(target, 1)
        end
    },
    -- grocery bag
    grocery_bag = {
        duratioin = nil,
        proc = false,
        onProc = function(source, target)

        end
    }
}

return marks