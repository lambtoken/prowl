local generate_pattern = require "src.render.components.generate_pattern"

local function new_pattern(pattern_data)
    local pattern_type = pattern_data[1]
    local pattern_shape = pattern_data[3]

    return generate_pattern(pattern_shape, pattern_type)
end

return new_pattern