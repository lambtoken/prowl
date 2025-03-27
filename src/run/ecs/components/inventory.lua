local Concord = require("libs.concord")

local inventory = Concord.component("inventory", function(component)
    component.items = {}
end)

return inventory