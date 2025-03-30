local Concord = require("libs.concord")

local metadata = Concord.component("metadata", function(component, species)
    component.species = species
    component.teamID = nil
    component.id = 0
end)

return metadata