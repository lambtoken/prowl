local Concord = require("libs.concord")

local metadata = Concord.component("metadata", function(component, species)
    component.species = species
    component.teamID = nil
end)

return metadata