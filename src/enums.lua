local createEnum = require "src.utility.enum"

local enums = {}

enums.stats = createEnum({
    ATK = "ATK",
    DEF = "DEF",
    CRIT = "CRIT",
    LIFESTEAL = "LIFESTEAL",
    LUCK = "LUCK",
    MAX_HEALTH = "MAX_HEALTH",
    PEN = "PEN",
})

enums.patterns = createEnum({
    ATK_PATTERN = "ATK_PATTERN",
    MOVE_PATTERN = "MOVE_PATTERN"
})