local mold = require "libs.mold"
local new_stats = require "src.render.components.tiny_stats"
local new_pattern = require "src.render.components.tiny_pattern"
local items = require "src.generation.items"

local function item_details(name)
    local item = items[name]

    local c = mold.Container:new()
    c:setWidth("auto")
    c:setHeight("auto")
    c:setPosition("absolute")
    c.bgColor = {0, 0, 0, 0.75}
    -- c:debug()

    local container = mold.Container:new()
    container:setWidth("auto")
    container:setHeight("auto")
    -- container.bgColor = {0, 0, 0, 1}
    -- container:setDirection("row")

    if item and item.name then
        local name = mold.TextBox:new(item.name)
            :setSize(20)
            :setColor({1, 1, 1, 1})
            -- :debug()
    
        c:addChild(name)
    end

    -- item description or passive descriptions missing rn

    if item and item.stats then
        if #item.stats > 0 then
            container:addChild(new_stats(item.stats))
        end
    end

    if item and item.pattern then
        for _, p in ipairs(item.pattern) do
            container:addChild(new_pattern(p))
        end
    end

    c:addChild(container)

    c:resize()
    return c
end

return item_details