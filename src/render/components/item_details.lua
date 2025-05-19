local mold = require "libs.mold"
local new_stats = require "src.render.components.tiny_stats"
local new_pattern = require "src.render.components.tiny_pattern"

local function item_details(item)
    local c = mold.Container:new()
    c.bgColor = {0, 0, 0, 1}

    local name = mold.TextBox(item.name)
    c:addChild(name)

    -- item description or passive descriptions

    for _, s in ipairs(item.stats) do
        c:addChild(new_stats(s))
    end

    for _, p in ipairs(item.patterns) do
        c:addChild(new_pattern(p))
    end

    return c
end

return item_details