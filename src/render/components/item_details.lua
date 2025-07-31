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

    local container = mold.Container:new()
    container:setWidth("auto")
    container:setHeight("auto")

    if item and item.name then
        local name = mold.TextBox:new(item.name)
            :setSize(25)
            :setColor({1, 1, 1, 1})
    
        c:addChild(name)
    end

    if item and item.passive and item.passive.description then
        local description = mold.TextBox:new(item.passive.description)
            :setSize(20)
            :setMargin("top", 20)
            :setColor({0.8, 0.8, 0.8, 1})
        
        c:addChild(description)
    end

    if item and item.stats then
        if #item.stats > 0 then
            local stats = new_stats(item.stats)
            stats:setMargin("top", 20)
            container:addChild(stats)
        end
    end

    if item and item.pattern then
        for _, p in ipairs(item.pattern) do
            local pattern = new_pattern(p)
            pattern:setMargin("top", 20)
            container:addChild(pattern)
        end
    end

    c:addChild(container)

    c:resize()
    return c
end

return item_details