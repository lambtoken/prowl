local mold = require "libs.mold"

local stat_size = 20

local function new_stat(stat)
    local sign, target, value, perc = "", "", "", ""

    if stat[1] == "increase" or stat[1] == "increaseP" then
        sign = "+"
        target = stat[2]
        value = stat[3]
    elseif stat[1] == "decrease" or stat[1] == "decreaseP" then
        sign = "-"
        target = stat[2]
        value = stat[3]
    elseif stat[1] == "swap" then
        sign = "swap "
        target = stat[2] .. " " .. stat[3]
    end

    if stat[1] == "increaseP" or stat[1] == "decreaseP" then
        perc = "%"
    end

    return mold.TextBox:new(sign .. target .. value .. perc)
        :setSize(stat_size)
        :setColor({1, 1, 1, 1})
        -- :debug()
end

local function new_stats(stats)

    local s = mold.Container:new()
    s.bgColor = {0, 0, 0, 1}

    s:setHeight("auto")
    s:setWidth("auto")
    s:debug()

    for _, value in ipairs(stats) do
        assert(type(value) == "table", "Stat is not a table!")
        s:addChild(new_stat(value))
    end

    return s
end

return new_stats