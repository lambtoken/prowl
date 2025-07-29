local mold = require "libs.mold"

local stat_size = 30

local function new_stat(stat, value)
    local s = mold.TextBox(stat .. ':' .. value)
        :setSize(stat_size)
        :setColor({1, 1, 1, 1})

    return s
end

local function new_stats(entityData)

    local s = mold.Container:new()

    s:setDirection("row")
    s:setWidth("200px")
    s:setHeight("100px")

    local row1 = mold.Container:new()
    local row2 = mold.Container:new()
    row1:setWidth("50%")
    row2:setWidth("50%")

    -- s:debug()

    local atk, def, crit, hp, ls

    if entityData.stats and entityData.stats.atk then
        atk = entityData.stats.atk
    else
        atk = '/'
    end

    if entityData.stats and entityData.stats.def then
        def = entityData.stats.def
    else
        def = '/'
    end

    if entityData.stats and entityData.stats.maxHp then
        hp = entityData.stats.maxHp
    else
        hp = '/'
    end

    if entityData.stats and entityData.stats.crit then
        crit = entityData.stats.crit
    else
        crit = '/'
    end

    if entityData.stats and entityData.stats.lifeSteal then
        ls = entityData.stats.lifeSteal
    else
        ls = '/'
    end

    row1:addChild(new_stat('atk', atk))
    row2:addChild(new_stat('def', def))
    row1:addChild(new_stat('crit', crit))
    row2:addChild(new_stat('ls', ls))
    row1:addChild(new_stat('hp', hp))

    s:addChild(row1)
    s:addChild(row2)

    return s

end

return new_stats