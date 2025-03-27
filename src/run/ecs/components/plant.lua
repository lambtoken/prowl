local Concord = require("libs.concord")

local plant = Concord.component("plant", function(c, species)
    c.species = species
end)

return plant