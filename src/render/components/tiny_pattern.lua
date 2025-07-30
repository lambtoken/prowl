local mold = require "libs.mold"
local generate_pattern = require "src.render.components.generate_pattern"

local function format_text(type, target)

    local s1 = ""
    local s2 = ""

    if type == "add" then
        s1 = "Add to the "
    elseif type == "extend" then
        s1 = "Extend the "
    elseif type == "remove" then
        s1 = "Remove from the "
    end

    if target == "movePattern" then
        s2 = "move pattern"
    elseif target == "atkPattern" then
        s2 = "attack pattern"
    end

    return s1 .. s2
end

local function new_pattern(pattern_data)
    local pattern_type = pattern_data[1]
    local pattern_target = pattern_data[2]
    local pattern_shape = pattern_data[3]

    local c = mold.Container:new()
        :setWidth("auto")
        :setHeight("auto")
        :setMargin("10px", "right")

    local text

    if pattern_type == "swap" then
        text = "Swap " .. pattern_target .. " with " .. pattern_shape -- shape is not shape in this case
    else
        text = format_text(pattern_type, pattern_target)  
    end

    local tb = mold.TextBox:new(text)
        :setMargin("10px", "bottom")
        :setSize(20)
        :setColor({1, 1, 1, 1})

    c:addChild(tb)

    if pattern_type ~= "swap" then
        c:addChild(generate_pattern(pattern_shape, pattern_type))
    end

    return c
end

return new_pattern