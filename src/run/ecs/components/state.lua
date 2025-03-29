local Concord = require("libs.concord")

local state = Concord.component("state", function(component, initialState)
    component.current = initialState or "alive"
    component.pickedUp = false
    component.currentTurnMoves = 0
    component.availableActions = 0
end)

return state