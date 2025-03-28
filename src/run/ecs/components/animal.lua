local Concord = require("libs.concord")

local animal = Concord.component("animal", function(component)
    component.effects = {}
end)

return animal