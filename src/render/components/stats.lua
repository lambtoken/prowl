local mold = require "libs.mold"

local stat_size = 35

local function new_stat(stat, value)
    local s = mold.TextBox(stat .. ':' .. value)
        -- :setHeight("auto")
        -- :setWidth("auto")
        :setSize(stat_size)
        :setColor({1, 1, 1, 1})

    return s
end

local function new_stats(entity)

    local s = mold.Container:new()

    s:setDirection("row")

    local row1 = mold.Container:new()
    local row2 = mold.Container:new()
    row1:setWidth("50%")
    row2:setWidth("50%")

    s:setWidth("200px")
    s:setHeight("200px")
    -- s:debug()

    local atk, def, crit, hp, ls

    if entity.stats and entity.stats.current and entity.stats.current.atk then
        atk = entity.stats.current.atk
    else
        atk = '/'
    end

    if entity.stats and entity.stats.current and entity.stats.current.def then
        def = entity.stats.current.def
    else
        def = '/'
    end

    if entity.stats and entity.stats.current and entity.stats.current.maxHp then
        hp = entity.stats.current.maxHp
    else
        hp = '/'
    end

    if entity.stats and entity.stats.current and entity.stats.current.crit then
        crit = entity.stats.current.crit
    else
        crit = '/'
    end

    if entity.stats and entity.stats.current and entity.stats.current.lifeSteal then
        ls = entity.stats.current.lifeSteal
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

-- name
-- hp: 20
-- atk: 2 def: 20
-- crit ls
-- pen luck

return new_stats