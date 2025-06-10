local animationData = require "src.render.match.animationData"
local tween = require "libs.tween"
local tablex = require "libs.batteries.tablex"
local getFont = require "src.render.getFont"
local pretty  = require "libs.batteries.pretty"

local class = require "libs.middleclass"

local id = 0

local UNIT_TYPES = {
    PIXELS = "px",
    PERCENT = "%",
    FR = "fr",
    AUTO = "auto"
}

local _UNIT_TYPES = {
    px = UNIT_TYPES.PIXELS,
    --"%" = UNIT_TYPES.PERCENT,
    auto = UNIT_TYPES.AUTO,
    fr = UNIT_TYPES.FR
}

_UNIT_TYPES["%"] = UNIT_TYPES.PERCENT

local POSITION_TYPES = {
    STATIC = "static",
    RELATIVE = "relative",
    FIXED = "fixed",
    ABSOLUTE = "absolute"
}

local FLEX_JUSTIFY = {
    START = "start",
    CENTER = "center",
    END = "end",
    SPACEBETWEEN = "space-between",
    SPACEAROUND = "space-around",
    SPACEEVENLY = "space-evenly"
}

local FLEX_ALIGN = {
    START = "start",
    CENTER = "center",
    END = "end",
}

local TYPE = {
    FLEX = "flex",
    GRID = "grid"
}

local FLEX_DIRECTION = {
    ROW = "row",
    COLUMN = "column"
}

local MODES = {
    NORMAL = "normal",
    SQUISH = "squish", -- squish everything
}

local OVERFLOW = {
    NOCLIP = "noclip",
    CLIP = "clip",
    SCROLL = "scroll"
}

local ROW_LOOKUP = {
    main_size = 'w',
    cross_size = 'h',
    main_pos = 'x',
    cross_pos = 'y',
    start_margin = 'left',
    end_margin = 'right',
    cross_start_margin = 'top',
    cross_end_margin = 'bottom'
}

local COLUMN_LOOKUP = {
    main_size = 'h',
    cross_size = 'w',
    main_pos = 'y',
    cross_pos = 'x',
    start_margin = 'top',
    end_margin = 'bottom',
    cross_start_margin = 'left',
    cross_end_margin = 'right'
}

local SCALE_BY = {
    WIDTH = "width",
    HEIGHT = "height"
}

-- local function emptyBox()
--     return {x = nil, y = nil, w = nil, h = nil}
-- end

local function clamp(value, bot, top)
    return math.max(bot, math.min(value, top))
end

local function parseUnit(value)
    local number, unit = tostring(value):match("^%s*(-?%d*%.?%d*)([a-z%%]*)%s*$")

    if value == "auto" then
        return { value = nil, unit = UNIT_TYPES.AUTO }
    end

    if number and unit then
        --print(number, unit)
        local num = tonumber(number)
        -- we can get nil here
        return { value = num, unit = _UNIT_TYPES[unit] }
    end

    -- Return nil if parsing fails
    return nil
end


local function parseShorthand(input)
    local result = { top = nil, right = nil, bottom = nil, left = nil }

    -- Split the margin string manually
    local parts = {}
    local start = 1
    while true do
        local spacePos = string.find(input, " ", start)
        local part
        if spacePos then
            part = string.sub(input, start, spacePos - 1)
            start = spacePos + 1
        else
            part = string.sub(input, start)
        end

        local parsedPart = parseUnit(part)
        assert(parsedPart, "Invalid shorthand part: " .. part)
        table.insert(parts, parsedPart)

        if not spacePos then break end
    end

    -- Assign values based on the number of parts
    if #parts == 1 then
        result.top, result.right, result.bottom, result.left = parts[1], parts[1], parts[1], parts[1]
    elseif #parts == 2 then
        result.top, result.right, result.bottom, result.left = parts[1], parts[2], parts[1], parts[2]
    elseif #parts == 3 then
        result.top, result.right, result.bottom, result.left = parts[1], parts[2], parts[3], parts[2]
    elseif #parts == 4 then
        result.top, result.right, result.bottom, result.left = parts[1], parts[2], parts[3], parts[4]
    else
        error("Invalid number of parts in margin string")
    end

    return result
end


local Box = class("Box")

function Box:initialize()
    self.id = id
    id = id + 1

    -- s = specified
    self.sx = nil
    self.sy = nil
    self.sw = nil
    self.sh = nil

    -- c = content
    self.cx = 0
    self.cy = 0
    self.cw = 0
    self.ch = 0

    -- p = padding
    self.px = nil
    self.py = nil
    self.pw = nil
    self.ph = nil

    -- m = margin
    self.mx = nil
    self.my = nil
    self.mw = nil
    self.mh = nil

    -- pivot
    self.sPivotX = 0.5
    self.sPivotY = 0.5
    self.cPivotX = 0
    self.cPivotY = 0

    self.transform = {
        translateX = 0,
        translateY =0,
        scaleX = 1,
        scaleY = 1,
        rotation = 0
    }

    -- use these if needed
    self.marginBox = nil
    self.paddingBox = nil

    self.sMargin = nil
    self.cMargin = {top = 0, right= 0, bottom = 0, left = 0}
    self.sPadding = nil
    self.cPadding = {top = 0, right= 0, bottom = 0, left = 0}
    self.minW = 0
    self.minH = 0
    self.maxW = nil
    self.maxH = nil
    self.position = POSITION_TYPES.STATIC
    self.display = nil
    self.overflow = OVERFLOW.NOCLIP
    self.dragCapturing = false

    self._dragCaptured = false
    self._mouseEntered = false

    self.bgColor = nil

    self.animations = {}

    self:setMargin("0px")
    self:setPadding("0px")
    self:setWidth("100%")
    self:setHeight("100%")
    self:setPos(0, 0)
end

function Box:resize() end

function Box:_setProperty(arg, propertyName)
    assert(type(arg) == "number" or type(arg) == "string", "Expected number or string. Instead got: " .. type(arg))

    local propertyValue
    if type(arg) == "number" then
        propertyValue = {value = arg, unit = UNIT_TYPES.PIXELS}
    elseif type(arg) == "string" then
        propertyValue = parseUnit(arg)
    end

    self[propertyName] = propertyValue
end

function Box:setMargin(...)

    if select("#", ...) == 1 then
        local str = ...
        self.sMargin = parseShorthand(str)
        return self
    elseif select("#", ...) == 2 then
        local str, side = ...
        self.sMargin[side] = parseUnit(str)
    end

    return self
end

function Box:setPosition(str)
    for key, value in pairs(POSITION_TYPES) do
        if value == str then
            self.position = str
            return self
        end
    end

    error("Invalid argument: " .. str, 1)
end

function Box:setOverflow(str)
    for key, value in pairs(OVERFLOW) do
        if value == str then
            self.overflow = str
            return self
        end
    end

    error("Invalid argument: " .. str, 1)
end


function Box:setPadding(str)
    self.sPadding = parseShorthand(str)
    return self
end

function Box:setWidth(arg)
    self:_setProperty(arg, "sw")
    return self
end

function Box:setHeight(arg)
    self:_setProperty(arg, "sh")
    return self
end

function Box:setMinWidth(arg)
    self:_setProperty(arg, "sminw")
    return self
end

function Box:setMinHeight(arg)
    self:_setProperty(arg, "sminh")
    return self
end

function Box:setMaxWidth(arg)
    self:_setProperty(arg, "smaxw")
    return self
end

function Box:setMaxHeight(arg)
    self:_setProperty(arg, "smaxh")
    return self
end

function Box:setPos(x, y)
    assert(type(x) == "number" and type(y) == "number", "Invalid arguments. Expected 2 numbers!")
    self.sx = x
    self.sy = y

    return self
end

function Box:onMouseMoved(x, y) end

function Box:onMouseEnter() end

function Box:onMouseExited() end

function Box:onMousePressed(x, y, click) end

function Box:onMouseReleased(x, y, click) end

function Box:getRoot()
    local e = self

    while not e.isRoot do
        if e.parent then
            e = e.parent
        else
            return nil
        end
    end

    return e
end

--Animation

function Box:createAnimation(name, loop)
    local anim = {}
    local sourceData = animationData[name]
    
    anim.cancelCategory = sourceData.cancelCategory or "none"
    anim.tweens = {}
    anim.name = name
    anim.loop = sourceData.loop or loop or false
    anim.stackable = sourceData.stackable or true
    anim.timePassed = 0
    anim.onFinish = sourceData.onFinish or function() end
    
    for _, tweenData in ipairs(sourceData.tweens) do
        local t = tablex.copy(tweenData)
        
        for k, v in pairs(t) do
            if type(v) == "function" then
                t[k] = v()
            end
        end
        
        t.x = t.from

        t.tween = tween.new(
            t.duration,
            t,
            {x = t.to},
            t.func
        )
        
        table.insert(anim.tweens, t)
    end

    return anim
end


function Box:playAnimation(name, loop)
    assert(animationData[name], "Animation " .. name .. " does not exist!")
    
    loop = loop or false
    
    table.insert(self.animations, self:createAnimation(name, loop))
    return self
end


function Box:stopAnimation(name)

    for _, animation in ipairs(self.animations) do 
        if animation.name == name then
            table.remove(self.animations, _)
        end
    end
end

function Box:removeAllAnimations()
    self.animations = {}
end

function Box:debug()
    self._debug = true
    self._debugColor = {math.random(), math.random(), math.random()}
    return self
end

function Box:draw()
    if self.bgColor then
        love.graphics.setColor(unpack(self.bgColor))
        -- love.graphics.rectangle("fill", self.cx, self.cy, self.cw, self.ch)
        love.graphics.rectangle("fill", -self.cPivotX, -self.cPivotY, self.cw, self.ch)
    end
end

function Box:__remove()
    self.parent = nil
end

-- units: px, percent, auto

local Container = class("Container", Box)

function Container:initialize()
    Box.initialize(self)

    self.type = TYPE.FLEX
    self.flexDirection = FLEX_DIRECTION.COLUMN
    self.justifyContent = FLEX_JUSTIFY.START
    self.alignContent = FLEX_ALIGN.START
    self.scrollPosition = 0
    self.parent = nil
    self.children = {}
    self._debug = false
end

function Container:addChild(child)
    assert(child, "Child is nil")
    child.parent = self
    table.insert(self.children, child)
    assert(self.children[#self.children] == child, "Child not added correctly")
    return self.children[#self.children]
end

function Container:addContainer()
    local newContainer = Container:new()
    newContainer.parent = self
    self:addChild(newContainer)
    return newContainer
end

function Container:removeChild(child)
    for i = #self.children, 1 , -1 do
        local c = self.children[i]
        if c == child then 
            table.remove(self.children, i)
        end
    end
end

function Container:setJustifyContent(str)
    for key, value in pairs(FLEX_JUSTIFY) do
        if value == str then
            self.justifyContent = str
            return self
        end
    end

    error("Invalid argument: " .. str, 1)
end

function Container:setDirection(str)
    for key, value in pairs(FLEX_DIRECTION) do
        if value == str then
            self.flexDirection = str
            return self
        end
    end

    error("Invalid argument: " .. str, 1)
end

function Container:setAlignContent(str)
    for key, value in pairs(FLEX_ALIGN) do
        if value == str then
            self.alignContent = str
            return self
        end
    end

    error("Invalid argument: " .. str, 1)
end

function Container:clearChildren()
    for _, child in ipairs(self.children) do
        child:__remove()
    end
    self.children = {}
end

function Container:resize()
    if self.isRoot then
        self.cPadding = {top = 0, right= 0, bottom = 0, left = 0}
        self.cMargin = {top = 0, right= 0, bottom = 0, left = 0}
    end

    self:_resizeChildren()
    self:_positionChildren()

    for _, child in ipairs(self.children) do
        child:resize()
    end

    if self.isRoot and self.children then self:flattenChildren() end
end

function Container:_resizeChildren()
    -- process px, percent, fr... in that order

    local props

    if self.flexDirection == FLEX_DIRECTION.COLUMN then
        props = COLUMN_LOOKUP
    elseif self.flexDirection == FLEX_DIRECTION.ROW then
        props = ROW_LOOKUP
    end

    -- this branch should not be here
    if self.isRoot then
        if self.sMargin then

            for key, side in pairs(self.sMargin) do
                if side.unit == UNIT_TYPES.PIXELS then
                    self.cMargin[key] = side.value
                elseif side.unit == UNIT_TYPES.PERCENT  then
                    assert(self.parent, "Cannot use percent if there is no parent.")
                    assert(self.parent.sw.unit ~= UNIT_TYPES.AUTO, "Parent width is AUTO, cannot infer margin from it.")

                    self.cMargin[key] = self.parent.cw * side.value / 100
                end
            end
        end

        if self.sPadding then

            for key, side in pairs(self.sPadding) do
                if side.unit == UNIT_TYPES.PIXELS then
                    self.cPadding[key] = side.value
                elseif side.unit == UNIT_TYPES.PERCENT  then
                    assert(self.parent, "Cannot use percent if there is no parent.")
                    assert(self.parent.sw.unit ~= UNIT_TYPES.AUTO, "Parent width is AUTO, cannot infer margin from it.")

                    self.cPadding[key] = self.parent.cw * side.value / 100
                end
            end
        end

        if self.sw.unit == UNIT_TYPES.PIXELS then
            self.cw = self.sw.value - self.cPadding.left - self.cPadding.right
            self.mw = self.sw.value
        end

        if self.sh.unit == UNIT_TYPES.PIXELS then
            self.ch = self.sh.value - self.cPadding.top - self.cPadding.bottom
            self.mh = self.sh.value
        end

    end

    local remainingSpace = self['c' .. props.main_size]

    -- main calc
    for _, child in ipairs(self.children) do
        if child.sMargin then

            for key, side in pairs(child.sMargin) do
                if side.unit == UNIT_TYPES.PIXELS then
                    child.cMargin[key] = side.value
                elseif side.unit == UNIT_TYPES.PERCENT  then
                    assert(child.parent, "Cannot use percent if there is no parent.")
                    assert(child.parent.sw.unit ~= UNIT_TYPES.AUTO, "Parent width is AUTO, cannot infer margin from it.")

                    child.cMargin[key] = child.parent.cw * side.value / 100
                elseif side.unit == UNIT_TYPES.AUTO then
                    child.cMargin[key] = 0
                end
            end
        end

        if child.sPadding then

            for key, side in pairs(child.sPadding) do
                if side.unit == UNIT_TYPES.PIXELS then
                    child.cPadding[key] = side.value
                elseif side.unit == UNIT_TYPES.PERCENT  then
                    assert(child.parent, "Cannot use percent if there is no parent.")
                    assert(child.parent.sw.unit ~= UNIT_TYPES.AUTO, "Parent width is AUTO, cannot infer margin from it.")

                    child.cPadding[key] = child.parent.cw * side.value / 100
                end
            end
        end

        local main_size_value = 0
        local cross_size_value = 0

        if child['s' .. props.main_size].unit == UNIT_TYPES.PIXELS then
            main_size_value = child['s' .. props.main_size].value
        end

        if child['s' .. props.cross_size].unit == UNIT_TYPES.PIXELS then
            cross_size_value = child['s' .. props.cross_size].value
        end

        if child['s' .. props.main_size].unit == UNIT_TYPES.PERCENT then
            local availableMainSize = self['c' .. props.main_size]
            availableMainSize = availableMainSize - child.cMargin[props.start_margin] - child.cMargin[props.end_margin]
            main_size_value = availableMainSize * child['s' .. props.main_size].value / 100
            main_size_value = clamp(main_size_value, 0, main_size_value)

        end

        if child['s' .. props.cross_size].unit == UNIT_TYPES.PERCENT then
            local availableCrossSize = self['c' .. props.cross_size]
            availableCrossSize = availableCrossSize - child.cMargin[props.cross_start_margin] - child.cMargin[props.cross_end_margin]
            cross_size_value = availableCrossSize * (child['s' .. props.cross_size].value / 100)
            cross_size_value = clamp(cross_size_value, 0, cross_size_value)
        end

        local _props

        if child.flexDirection == FLEX_DIRECTION.ROW then
            _props = ROW_LOOKUP
        elseif child.flexDirection == FLEX_DIRECTION.COLUMN then
            _props = COLUMN_LOOKUP
        end
        
        if child.children then
            if child['s' .. _props.main_size].unit == UNIT_TYPES.AUTO then
                child:_resizeChildren()
                
                local total = 0
                for i, ch in ipairs(child.children) do
                    total = total + ch['m' .. _props.main_size]
                end
                
                if _props == ROW_LOOKUP then
                    cross_size_value = total
                else
                    main_size_value = total
                end
            end
            
            if child['s' .. _props.cross_size].unit == UNIT_TYPES.AUTO then
                child:_resizeChildren()
    
                local largest = 0
                for i, ch in ipairs(child.children) do
                    largest = ch['m' .. _props.cross_size] > largest and ch['m' .. _props.cross_size] or largest
                end
    
                if _props == ROW_LOOKUP then
                    main_size_value = largest
                else
                    cross_size_value = largest
                end
            end
        end

        -- HACK. should figure out a better solution when i refactor all this crap
        if self.flexDirection == FLEX_DIRECTION.ROW and _props and
        child['s' .. _props.cross_size].unit == UNIT_TYPES.AUTO then
            local temp = main_size_value
            main_size_value = cross_size_value
            cross_size_value = temp
        end

        -- calc minmax size
        local minMain = child["smin" .. props.main_size]
        local minCross = child["smin" .. props.cross_size]

        if minMain then
            if minMain.unit == UNIT_TYPES.PIXELS then
                child["cmin" .. props.main_size] = minMain.value
            end

            if minMain.unit == UNIT_TYPES.PERCENT then
                child["cmin" .. props.main_size] = child.parent["c" .. props.main_size] / 100 * minMain.value
            end
        end

        if minCross then
            if minCross.unit == UNIT_TYPES.PIXELS then
                child["cmin" .. props.cross_size] = minCross.value
            end

            if minCross.unit == UNIT_TYPES.PERCENT then
                child["cmin" .. props.cross_size] = child.parent["c" .. props.cross_size] / 100 * minCross.value
            end
        end

        local maxMain = child["smax" .. props.main_size]
        local maxCross = child["smax" .. props.cross_size]

        if maxMain then
            if maxMain.unit == UNIT_TYPES.PIXELS then
                child["cmax" .. props.main_size] = minMain.value
            end

            if maxMain.unit == UNIT_TYPES.PERCENT then
                child["cmax" .. props.main_size] = child.parent["c" .. props.main_size] / 100 * maxMain.value
            end
        end

        if maxCross then
            if maxCross.unit == UNIT_TYPES.PIXELS then
                child["cmax" .. props.cross_size] = maxCross.value
            end

            if maxCross.unit == UNIT_TYPES.PERCENT then
                child["cmax" .. props.cross_size] = child.parent["c" .. props.cross_size] / 100 * maxCross.value
            end
        end

        if minMain then
            main_size_value = math.max(main_size_value, child["cmin" .. props.main_size])
        end

        if minCross then
            cross_size_value = math.max(cross_size_value, child["cmin" .. props.cross_size])
        end

        if maxMain then
            main_size_value = math.min(main_size_value, child["cmax" .. props.main_size])
        end

        if maxCross then
            cross_size_value = math.min(cross_size_value, child["cmax" .. props.cross_size])
        end

        if child.scaleBy then
            if props.main_size == "w" then
                main_size_value, cross_size_value = child:_handleAspectRatio(main_size_value, cross_size_value)
            else
                cross_size_value, main_size_value = child:_handleAspectRatio(cross_size_value, main_size_value)
            end
        end

        -- calculate pivots
        if child.sPivotX then
            if props.main_size == "w"then
                child.cPivotX = child.sPivotX * main_size_value
            else
                child.cPivotX = child.sPivotX * cross_size_value
            end
        end

        if child.sPivotY then
            if props.main_size == "w"then
                child.cPivotY = child.sPivotY * main_size_value
            else
                child.cPivotY = child.sPivotY * cross_size_value
            end
        end

        -- auto margin for fixed
        if child.position == POSITION_TYPES.FIXED then
            local remainingMain = child.parent["m" .. props["main_size"]]
            local remainingCross = child.parent["m" .. props["cross_size"]]

            remainingMain = remainingMain - child.cMargin[props.start_margin] - child.cMargin[props.end_margin] - main_size_value
            remainingCross = remainingCross - child.cMargin[props.cross_start_margin] - child.cMargin[props.cross_end_margin] - cross_size_value

            if child.sMargin[props.start_margin].unit == UNIT_TYPES.AUTO and
                child.sMargin[props.end_margin].unit == UNIT_TYPES.AUTO then

                remainingMain = remainingMain / 2
                child.cMargin[props.start_margin] = remainingMain
                child.cMargin[props.end_margin] = remainingMain

            elseif child.sMargin[props.start_margin].unit == UNIT_TYPES.AUTO then
                child.cMargin[props.start_margin] = remainingMain

            elseif child.sMargin[props.end_margin].unit == UNIT_TYPES.AUTO then
                child.cMargin[props.end_margin] = remainingMain
            end

            if child.sMargin[props.cross_start_margin].unit == UNIT_TYPES.AUTO and
            child.sMargin[props.cross_end_margin].unit == UNIT_TYPES.AUTO then

                remainingMain = remainingMain / 2
                child.cMargin[props.cross_start_margin] = remainingMain
                child.cMargin[props.cross_end_margin] = remainingMain

            elseif child.sMargin[props.cross_start_margin].unit == UNIT_TYPES.AUTO then
                child.cMargin[props.cross_start_margin] = remainingMain

            elseif child.sMargin[props.cross_end_margin].unit == UNIT_TYPES.AUTO then
                child.cMargin[props.cross_end_margin] = remainingMain
            end
        end

        local marginbox_main_size_value = main_size_value + child.cMargin[props.start_margin] + child.cMargin[props.end_margin]

        child['p' .. props.main_size] = main_size_value
        child['m' .. props.main_size] = marginbox_main_size_value
        child['p' .. props.cross_size] = cross_size_value
        child['m' .. props.cross_size] = cross_size_value + child.cMargin[props.cross_start_margin] + child.cMargin[props.cross_end_margin]

        if child.cPadding[props.start_margin] + child.cPadding[props.end_margin] > main_size_value then
            child['c' .. props.main_size] = 0
        else
            child['c' .. props.main_size] = main_size_value - child.cPadding[props.start_margin] - child.cPadding[props.cross_end_margin]
        end

        -- print(child['c' .. props.main_size], props.main_size)
        
        if child.cPadding[props.cross_start_margin] + child.cPadding[props.cross_end_margin] > cross_size_value then
            child['c' .. props.cross_size] = 0
        else
            child['c' .. props.cross_size] = cross_size_value - child.cPadding[props.cross_start_margin] - child.cPadding[props.cross_end_margin]
        end
        
        -- print(child['c' .. props.cross_size], props.cross_size)

        if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
            remainingSpace = remainingSpace - marginbox_main_size_value
        end
    end

    -- calculate FRs
    if remainingSpace > 0 then
        local frChildren = {}
        local totalFr = 0

        for index, child in ipairs(self.children) do
            if child['s' .. props.main_size].unit == UNIT_TYPES.FR then
                local fr = child['s' .. props.main_size].value
                table.insert(frChildren, {index, fr})
                totalFr = totalFr + fr
            end
        end

        if totalFr > 0 then
            local frValue = remainingSpace / totalFr

            for index, value in ipairs(frChildren) do

                local child = self.children[value[1]]

                local newSize = frChildren[index][2] * frValue
                child['p' .. props.main_size] = newSize
                child['c' .. props.main_size] = newSize
                child['m' .. props.main_size] = child['m' .. props.main_size] + newSize
                remainingSpace = remainingSpace - newSize
            end
        end
    end

    --calculate AUTO margins if any
    if remainingSpace > 0 then
        local marginChildren = {}

        for index, child in ipairs(self.children) do
            if child.position == POSITION_TYPES.FIXED then
                goto continue
            end
            if child.sMargin[props.start_margin] and child.sMargin[props.start_margin].unit == UNIT_TYPES.AUTO then
                table.insert(marginChildren, {index, props.start_margin})
            end
            if child.sMargin[props.end_margin] and child.sMargin[props.end_margin].unit == UNIT_TYPES.AUTO then
                table.insert(marginChildren, {index, props.end_margin})
            end
            ::continue::
        end

        if #marginChildren > 0 then

            local marginSlice = remainingSpace / #marginChildren
            for index, marginData in ipairs(marginChildren) do
                local child = self.children[marginData[1]]
                child.cMargin[marginData[2]] = marginSlice
                child['m' .. props.main_size] = child['m' .. props.main_size] + marginSlice
            end
        end

    end
end

-- i hate this function, and i bet it hates me back for creating it
function Container:_positionChildren()

    if self.isRoot then
        self.cx = self.cPadding.left
        self.cy = self.cPadding.top
    end

    local props
    if self.flexDirection == FLEX_DIRECTION.ROW then
        props = ROW_LOOKUP
    elseif self.flexDirection == FLEX_DIRECTION.COLUMN then
        props = COLUMN_LOOKUP
    end

    local pos
    local childrenTotalSize = 0
    local numChildren = 0

    for _, child in ipairs(self.children) do
        if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
            childrenTotalSize = childrenTotalSize + child['m' .. props['main_size']]
            numChildren = numChildren + 1
        end
    end

    if self.overflow == OVERFLOW.SCROLL then
        self._childrenTotalSize = childrenTotalSize
    end

    local function paddingPos(child)
        local x
        local y

        if child.cPadding[props.start_margin] + child.cPadding[props.end_margin] > child['c' .. props.main_size] then
            x = child.cPadding[props.start_margin]
        end

        if child.cPadding[props.cross_start_margin] + child.cPadding[props.cross_end_margin] > child['c' .. props.cross_size] then
            y = child.cPadding[props.cross_start_margin]
        end

        return x or math.abs(math.abs(child.cPadding[props.start_margin]) - math.abs(child.cPadding[props.end_margin])),
               y or math.abs(math.abs(child.cPadding[props.cross_start_margin]) - math.abs(child.cPadding[props.cross_end_margin]))
    end

    if self.justifyContent == FLEX_JUSTIFY.START then
        pos = self['c' .. props['main_pos']]
        for _, child in ipairs(self.children) do
            local x = pos + child.cMargin[props['start_margin']] - self.scrollPosition
            local y = self['c' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]

            y = self:_alignChildren(self, child, props)

            local px, py = paddingPos(child)
            x, y = x + px, y + py
            self:_setPos(child, x, y, props)

            if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
                pos = pos + child['m' .. props['main_size']]
            end
        end
    end


    if self.justifyContent == FLEX_JUSTIFY.END then
        pos = self['c' .. props['main_pos']] + self['c' .. props['main_size']] - childrenTotalSize
        for _, child in ipairs(self.children) do
            local x = pos + child.cMargin[props['start_margin']]
            local y = self['c' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]

            y = self:_alignChildren(self, child, props)

            local px, py = paddingPos(child)
            x, y = x + px, y + py

            self:_setPos(child, x, y, props)

            if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
                pos = pos + child['m' .. props['main_size']]
            end
        end
    end

    if self.justifyContent == FLEX_JUSTIFY.CENTER then
        pos = self['c' .. props['main_pos']]
        local aroundSize = clamp(self['c' .. props['main_size']] - childrenTotalSize, 0, self['c' .. props['main_size']])
        aroundSize = aroundSize / (numChildren * 2)

        for _, child in ipairs(self.children) do

            local childPos = pos + child.cMargin[props['start_margin']] + aroundSize

            local x = childPos
            local y = self['c' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]

            y = self:_alignChildren(self, child, props)

            local px, py = paddingPos(child)
            x, y = x + px, y + py

            self:_setPos(child, x, y, props)

            if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
                pos = pos + aroundSize * 2 + child['m' .. props['main_size']]
            end
        end
    end

    if self.justifyContent == FLEX_JUSTIFY.SPACEAROUND then
        pos = self['c' .. props['main_pos']]
        local aroundSize = clamp(self['c' .. props['main_size']] - childrenTotalSize, 0, self['c' .. props['main_size']])
        aroundSize = aroundSize / (numChildren * 2)

        for _, child in ipairs(self.children) do

            local childPos = pos + child.cMargin[props['start_margin']] + aroundSize

            local x = childPos
            local y = self['c' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]

            y = self:_alignChildren(self, child, props)

            local px, py = paddingPos(child)
            x, y = x + px, y + py

            self:_setPos(child, x, y, props)

            if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
                pos = pos + aroundSize * 2 + child['m' .. props['main_size']]
            end
        end
    end


    if self.justifyContent == FLEX_JUSTIFY.SPACEBETWEEN then
        pos = self['c' .. props['main_pos']]
        local betweenSize = clamp(self['c' .. props['main_size']] - childrenTotalSize, 0, self['c' .. props['main_size']])
        betweenSize = betweenSize / (numChildren - 1)

        for _, child in ipairs(self.children) do

            local childPos = pos + child.cMargin[props['start_margin']]

            local x = childPos
            local y = self['c' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]

            y = self:_alignChildren(self, child, props)

            local px, py = paddingPos(child)
            x, y = x + px, y + py

            self:_setPos(child, x, y, props)

            if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
                pos = pos + betweenSize + child['m' .. props['main_size']]
            end
        end
    end

    if self.justifyContent == FLEX_JUSTIFY.SPACEEVENLY then
        pos = self['c' .. props['main_pos']]
        local aroundSize = clamp(self['c' .. props['main_size']] - childrenTotalSize, 0, self['c' .. props['main_size']])
        aroundSize = aroundSize / ((numChildren + 1) * 2)

        for index, child in ipairs(self.children) do

            local childOffset = aroundSize

            if index == 1 then
                childOffset = childOffset + aroundSize
            end

            local childPos = pos + child.cMargin[props['start_margin']] + childOffset

            local x = childPos
            local y = self['c' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]

            y = self:_alignChildren(self, child, props)

            local px, py = paddingPos(child)
            x, y = x + px, y + py

            self:_setPos(child, x, y, props)

            if child.position == POSITION_TYPES.STATIC or child.position == POSITION_TYPES.RELATIVE then
                pos = pos + childOffset + aroundSize + child['m' .. props['main_size']]
            end
        end
    end

    -- Set scissor
    for index, child in ipairs(self.children) do
        if child.parent and child.parent.overflow == OVERFLOW.CLIP or child.parent.overflow == OVERFLOW.SCROLL then
            local parent_scissor_x = child.parent.scissorX or child.parent.cx
            local parent_scissor_y = child.parent.scissorY or child.parent.cy
            local parent_scissor_w = child.parent.scissorW or child.parent.cw
            local parent_scissor_h = child.parent.scissorH or child.parent.ch
            child.scissorX = math.max(child.cx, parent_scissor_x)
            child.scissorY = math.max(child.cy, parent_scissor_y)
            child.scissorW = math.max(0, math.min(child.cw, parent_scissor_x + parent_scissor_w - child.scissorX))
            child.scissorH = math.max(0, math.min(child.ch, parent_scissor_y + parent_scissor_h - child.scissorY))
        else
            child.scissorX = child.cx
            child.scissorY = child.cy
            child.scissorW = child.cw
            child.scissorH = child.ch
        end
    end
end

function Container:_alignChildren(parent, child, props)

    if parent.alignContent == FLEX_ALIGN.START then
        return parent['c' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]
    end

    if parent.alignContent == FLEX_ALIGN.END then
        return parent['c' .. props['cross_pos']] + parent['c' .. props['cross_size']] - child['m' .. props['cross_size']]
    end

    if parent.alignContent == FLEX_ALIGN.CENTER then
        return parent['c' .. props['cross_pos']] + parent['c' .. props['cross_size']] / 2
        - child['m' .. props['cross_size']] / 2 + child.cMargin[props['cross_start_margin']] -- ugly fix
    end
end

function Container:_setPos(child, x, y, props)
    if child.position == POSITION_TYPES.STATIC then
        child['c' .. props['main_pos']] = x
        child['c' .. props['cross_pos']] = y
    end

    if child.position == POSITION_TYPES.RELATIVE then
        child['c' .. props['main_pos']] = x + child['s' .. props['main_pos']]
        child['c' .. props['cross_pos']] = y + child['s' .. props['cross_pos']]
    end

    if child.position == POSITION_TYPES.FIXED then
        child['c' .. props['main_pos']] = child['s' .. props['main_pos']] + child.cMargin[props['start_margin']]
        child['c' .. props['cross_pos']] = child['s' .. props['cross_pos']] + child.cMargin[props['cross_start_margin']]
        -- oh God why am I adding margin in here
    end

    if child.position == POSITION_TYPES.ABSOLUTE then
        child['c' .. props['main_pos']] = child['s' .. props['main_pos']]
        child['c' .. props['cross_pos']] = child['s' .. props['cross_pos']]
    end
end

function Container:flattenChildren()
    local level = 0

    local stack = {self}
    self.flattened = {}

    while #stack > 0 do
        local node = table.remove(stack)

        if node.children then
            for index, child in ipairs(node.children) do
                table.insert(self.flattened, {child = child, level = level})
                table.insert(stack, child)
            end
        end

        level = level + 1
    end

    local reversed = {}
    for i = #self.flattened, 1, -1 do
        table.insert(reversed, self.flattened[i])
    end
    self.flattened = reversed
end

function Container:collectTweens()
    for _, entity in ipairs(self.flattened) do 
        local animationComponent = entity.child
        
        local sums = {
            translateX = 0,
            translateY = 0,
            scaleX = 1,
            scaleY = 1,
            rotation = 0
        }
        
        if #animationComponent.animations > 0 then
            
            for _, animation in ipairs(animationComponent.animations) do 
                for _, t in ipairs(animation.tweens) do
                    if animation.timePassed >= t.delay and animation.timePassed < (t.delay + t.tween.duration) and not t.tween:isComplete() or animation.loop then
                        sums[t.target] = sums[t.target] + t.x
                    end
                end
            end

        end

        animationComponent.transform.translateX = 0
        animationComponent.transform.translateY = 0
        animationComponent.transform.scaleX = 1
        animationComponent.transform.scaleY = 1
        animationComponent.transform.rotation = 0

        for property, sum in pairs(sums) do
            if property == "translateX" or property == "translateY" then 
                sum = math.floor(sum + 0.5)
            end
            animationComponent.transform[property] = sum
        end
    end
end

function Container:updateAnimations(dt)

    for _, entity in ipairs(self.flattened) do 
        local animationComponent = entity.child
        if not animationComponent or not animationComponent.animations then
            goto continue
        end

        for i = #animationComponent.animations, 1, -1 do
            local animation = animationComponent.animations[i]
            animation.timePassed = animation.timePassed + dt

            local allTweensComplete = true
            for _, t in ipairs(animation.tweens) do
                if animation.timePassed >= t.delay then
                    if not t.tween:update(dt) then
                        allTweensComplete = false
                    end
                else
                    allTweensComplete = false
                    break
                end
            end

            if allTweensComplete then
                if animation.loop then
                    animation.timePassed = 0
                    -- reset
                    for _, t in ipairs(animation.tweens) do
                        t.tween:reset()
                        t.x = t.from
                    end
                else
                    if animation.onFinish then
                        animationData[animation.name].onFinish(entity)
                    end
                    table.remove(animationComponent.animations, i)
                end
            end
        end

        ::continue::
    end

    self:collectTweens()
end


function Container:keyPressed(key)
    for index, child in ipairs(self.children) do
        if child.keyPressed then
            child:keyPressed(key)
        end
    end
end


function Container:mouseMoved(x, y)
    if not self.flattened then return end

    local topmost = nil
    local capturedChild = nil

    -- first pass: find captured child
    for _, childObj in ipairs(self.flattened) do
        if childObj.child._dragCaptured then
            capturedChild = childObj.child
            break
        end
    end

    -- second pass if no child yet get the topmost
    if not capturedChild then
        for _, childObj in ipairs(self.flattened) do
            local child = childObj.child
            if (x > child.scissorX and x < child.scissorX + child.scissorW) and
               (y > child.scissorY and y < child.scissorY + child.scissorH) then
                topmost = child
                break
            end
        end
    end

    local activeChild = capturedChild or topmost

    -- First pass: handle mouse exited
    for _, childObj in ipairs(self.flattened) do
        local child = childObj.child
        local isInside = (child == activeChild)

        if not isInside and child._mouseEntered then
            child._mouseEntered = false
            if child.onMouseExited then child:onMouseExited() end
        end
    end

    -- Second pass: handle mouse entered and moved
    for _, childObj in ipairs(self.flattened) do
        local child = childObj.child
        local isInside = (child == activeChild)

        if isInside then
            if not child._mouseEntered then
                child._mouseEntered = true
                if child.onMouseEnter then child:onMouseEnter() end
            end
            if child.onMouseMoved then child:onMouseMoved(x, y) end
        end
    end
end


function Container:mousePressed(x, y, click)
    if self.flattened and click == 1 then
        local topmost = nil

        for _, childObj in ipairs(self.flattened) do
            local child = childObj.child
            if x > child.scissorX and x < child.scissorX + child.scissorW
            and y > child.scissorY and y < child.scissorY + child.scissorH
            and not child.ignoreClick then
                topmost = child
                break
            end
        end

        for _, childObj in ipairs(self.flattened) do
            local child = childObj.child
            if child == topmost then
                child._mousePressed = true
                child:onMousePressed(x, y, click)
                child._dragCaptured = true
            else
                child._mousePressed = false
            end
        end
    end
end

function Container:mouseReleased(x, y, click)
    if self.flattened and click == 1 then
        local pressedChild = nil

        for _, childObj in ipairs(self.flattened) do
            if childObj.child._mousePressed then
                pressedChild = childObj.child
                break
            end
        end

        if pressedChild then
            pressedChild:onMouseReleased()
            pressedChild._dragCaptured = false
        end

        for _, childObj in ipairs(self.flattened) do
            childObj.child._mousePressed = false
        end
    end
end

function Container:handleScroll(x, y)
    if self.flattened then
        local mouseX, mouseY = love.mouse.getPosition()
        local scrollTargets = {}

        -- Find all scrollable elements under the mouse
        for _, childObj in ipairs(self.flattened) do
            local child = childObj.child
            if mouseX > child.scissorX and mouseX < child.scissorX + child.scissorW
            and mouseY > child.scissorY and mouseY < child.scissorY + child.scissorH then
                table.insert(scrollTargets, child)
            end
        end

        -- Scroll from the deepest to the highest container
        for i = #scrollTargets, 1, -1 do
            local target = scrollTargets[i]

            -- If it's a scroll container, scroll it
            if target.overflow == OVERFLOW.SCROLL then
                local main_size = target.flexDirection == FLEX_DIRECTION.ROW and "w" or "h"
                local amount = -y * 7
                local prevScroll = target.scrollPosition
                target.scrollPosition = clamp(target.scrollPosition + amount, 0, target._childrenTotalSize - target["c" .. main_size])

                -- Only apply child positioning if the scroll actually changed
                if target.scrollPosition ~= prevScroll then
                    target:resize()
                    return -- Stop propagating scroll if this container handled it
                end
            end
        end
    end
end

function Container:update(dt)

    if self.isRoot then
        self:updateAnimations(dt)
    end

    for _, child in ipairs(self.children) do
        if child.update then child:update(dt) end
    end
end

function Container:draw()
    
    if self.isRoot then
        love.graphics.push()
        love.graphics.translate(self.cPadding.left, self.cPadding.top)
    end

    Box.draw(self)

    local clip = self.overflow == OVERFLOW.CLIP or self.overflow == OVERFLOW.SCROLL

    if clip then
        love.graphics.push()
        love.graphics.setScissor(self.scissorX, self.scissorY, self.scissorW, self.scissorH)
    end

    for _, child in ipairs(self.children) do
        love.graphics.push()
        local parentX = child.parent and child.parent.cx or 0
        local parentY = child.parent and child.parent.cy or 0
        local parentW = child.parent and child.parent.cPivotX or 0
        local parentH = child.parent and child.parent.cPivotY or 0

        if child.position == POSITION_TYPES.FIXED then
            love.graphics.origin()
            love.graphics.translate(
                child.cx + child.cPivotX,
                child.cy + child.cPivotY
            )
        else
            love.graphics.translate(
                child.cx - parentX + child.cPivotX - parentW,
                child.cy - parentY + child.cPivotY - parentH
            )
        end

        love.graphics.scale(child.transform.scaleX, child.transform.scaleY)
        love.graphics.rotate(child.transform.rotation)
        love.graphics.translate(child.transform.translateX, child.transform.translateY)
        -- if child.overflow == OVERFLOW.CLIP then
        --     love.graphics.intersectScissor(child.cx, child.cy, child.cw, child.ch)
        -- end
        child:draw()
        if child._debug then
            love.graphics.setColor(unpack(child._debugColor))
            love.graphics.rectangle("line", -child.cPivotX, -child.cPivotY, child.cw, child.ch)
            -- love.graphics.rectangle("line", -child.cPivotX - child.cMargin.left, -child.cPivotY - child.cMargin.top, child.mw, child.mh)
        end

        -- love.graphics.setScissor(self.scissorX, self.scissorY, self.scissorW, self.scissorH)
        love.graphics.pop()
    end

    if clip then
        love.graphics.pop()
        love.graphics.setScissor()
    end


    if self.isRoot then
        love.graphics.setScissor()
        love.graphics.pop()
    end
end

function Container:setRoot(w, h)
    self.sw = {unit = UNIT_TYPES.PIXELS, value = w}
    self.sh = {unit = UNIT_TYPES.PIXELS, value = h}
    self.sx = 0
    self.sy = 0
    self.scissorX = 0
    self.scissorY = 0
    self.scissorW = w
    self.scissorH = h
    self.isRoot = true
    self.wheelMoved = self.handleScroll
    return self
end

function Box:printTree(prefix, isLast)
    prefix = prefix or ""
    isLast = isLast or true

    local linePrefix = isLast and "└── " or "├── "
    print(prefix .. linePrefix .. self.class.name)

    local childPrefix = prefix .. (isLast and "    " or "│   ")

    if self.children then
        for i, child in ipairs(self.children) do
            local isChildLast = (i == #self.children)
            child:printTree(childPrefix, isChildLast)
        end
    end
end


local function parseText(input)
    local result = {}
    local index = 1

    local function addText(text, styles)
        table.insert(result, { text = text, style = styles })
    end

    local pattern = "%[style=([^%]]+)%](.-)%[/style%]"

    while index <= #input do
        local startPos, endPos, styles, content = input:find(pattern, index)
        if startPos then
            -- Add text before the match (if any)
            if startPos > index then
                addText(input:sub(index, startPos - 1), nil)
            end

            local styleTable = {}
            for style in styles:gmatch("[^,]+") do
                if style:find(":") then
                    local key, value = style:match("([^:]+):(.+)")
                    styleTable[key] = value
                else
                    styleTable[style] = true
                end
            end

            addText(content, styleTable)

            index = endPos + 1
        else
            -- Add the remaining text as plain text
            addText(input:sub(index), nil)
            break
        end
    end

    return result
end


local TextRow = class("TextRow", Box)

function TextRow:initialize(str, box)
    Box.initialize(self)

    self.text = str or nil
    self.textBox = box
    self.bgColor = nil
    self.formatted = {}
    self.ignoreClick = true
    -- self:debug()
    -- self:setWidth("auto")
    -- self:setHeight("auto")
end

local function setup(row)
    -- styles: bold, italic, color, size, relsize

    local totalWidth = 0
    local maxHeight = 0

    for _, text in ipairs(row.formatted) do

        local size
        local font
        if text.style then
            if text.style.size then
                size = tonumber(text.style.size)
            elseif text.style.relSize then
                size = row.textBox.fontSize + text.style.relSize
            else
                size = row.textBox.fontSize
            end
        else
            size = row.textBox.fontSize
        end

        font = getFont("basis33", size)
        -- if text.font then
        --     font = love.graphics.newFont(text.font, size)
        -- elseif self.textBox.font then
        --     font = love.graphics.newFont(self.textBox.font, size)
        -- else
        -- end

        local width = font:getWidth(text.text)
        local height = font:getHeight()

        totalWidth = totalWidth + width
        maxHeight = height > maxHeight and height or maxHeight

        text.size = size
        text.font = font
        text.width = width
        text.height = height
    end
end

-- go word by word
-- if word exceeds and its not the start of the row go to next row
-- if word exceeds and it is start of the row add ... and its done

-- text.text:gmatch("^%S+")

function TextRow:draw()
    Box.draw(self)

    local pos = 0

    for i, text in ipairs(self.formatted) do

        -- we can also move this elsewhere but ok
        if text.style and text.style.color then
            if text.style.color == "red" then
                love.graphics.setColor(1, 0, 0, 1)
            end
        elseif self.textBox.color then
            love.graphics.setColor(unpack(self.textBox.color))
        else
            love.graphics.setColor(1, 1, 1, 1)
        end

        local x = -self.cPivotX + pos
        local y = -self.cPivotY + self.ch - text.height

        pos = pos + text.width

        love.graphics.setFont(text.font)
        love.graphics.print(text.text, x, y)
    end

end


TextBox = class("TextBox", Container)

function TextBox:initialize(str)
    Container.initialize(self)

    self.text = ""
    self.fontSize = 16
    self.fontName = "basis33"
    self:setWidth("auto")
    self:setHeight("auto")
    self:alignText("start")
    if str then
        self:setText(str)
    end
    self.font = nil
    self.bgColor = nil
    self.color = {0, 0, 0, 1}
    self.lineSpacing = 0
    self.ignoreClick = true

    -- self:setOverflow("clip")
end

-- function TextBox:resize()
--     for index, child in ipairs(self.children) do
--         if index ~= #self.children then
--             child:setMargin(tostring(self.lineSpacing) .. "px", "bottom")
--         end
--     end

--     Container.resize(self)
-- end

function TextBox:setText(str)
    self.text = str
    self:_processText()
    --self:resize()
end

function TextBox:setFont(font)
    self.font = font
end

function TextBox:setColor(r, g, b, a)
    self.color = {r, g, b, a}
    return self
end

function TextBox:_processText()

    self.children = {}

    for s in self.text:gmatch("[^\r\n]+") do
        local newRow = TextRow:new(s, self)
        self:addChild(newRow)
    end

    -- if self.sw.unit ~= UNIT_TYPES.AUTO and self.sh.unit ~= UNIT_TYPES.AUTO then
    self:wrap()
    self:resize()
end

function TextBox:setSize(size)
    self.fontSize = size
    self:_processText()
    return self
end

TextBox.__instanceDict.setAlignContent = nil

function TextBox:alignText(str)
    Container.setAlignContent(self, str)
    return self
end

function TextBox:wrap()
    local rowHeight
    local rowLength
    local totalHeight = 0
    local wrap = false

    local rows = {}

    for _, row in ipairs(self.children) do
        local left = 1
        local right = 1

        local newRow = TextRow:new()
        newRow.parent = self
        newRow.textBox = self
        table.insert(rows, newRow)
        rowLength = 0
        rowHeight = 0

        row.formatted = parseText(row.text)
        setup(row)

        for _, text in ipairs(row.formatted) do

            if text.height > rowHeight then
                rowHeight = text.height
            end

            if self.sh.unit ~= UNIT_TYPES.AUTO and totalHeight + rowHeight > self.ch then
                goto skip
            end

            -- iter throught each segment
            local lastSpace

            while right <= left + #text.text do

                if string.sub(text.text, right, right) == " " then
                    lastSpace = right
                end

                local sub = string.sub(text.text, left, right)

                local overflow = rowLength + text.font:getWidth(sub) > self.cw

                if  self.sw.unit ~= UNIT_TYPES.AUTO and overflow then
                    if lastSpace and lastSpace ~= right then
                        right = lastSpace
                    end

                    if  not lastSpace and rowLength == 0 then
                        text.text = string.sub(text.text, left, right - 1)
                        text.width = text.font:getWidth(text.text)
                        table.insert(rows[#rows].formatted, text)
                        wrap = true
                        goto skip
                    end

                    local newText = { text =  string.sub(text.text, left, right), style = text.style}
                    newText.height = text.height
                    newText.width = text.font:getWidth(newText.text)
                    newText.font = text.font

                    table.insert(rows[#rows].formatted, newText)

                    local newRow = TextRow:new()
                    newRow.parent = self
                    newRow.textBox = self
                    table.insert(rows, newRow)

                    while string.sub(text.text, right, right) == " " and right <= #text.text do
                        right = right + 1
                    end

                    totalHeight = totalHeight + rowHeight
                    left = right
                    rowLength = 0
                    rowHeight = 0
                    lastSpace = nil
                end

                if right == left + #text.text then
                    local newText = { text = string.sub(text.text, left, right), style = text.style}
                    newText.height = text.height
                    newText.width = text.font:getWidth(newText.text)
                    newText.font = text.font
                    table.insert(rows[#rows].formatted, newText)
                end

                right = right + 1
            end

        end
    end

    ::skip::
    if wrap then
        local row = rows[#rows].formatted
        row[#row].text = string.sub(row[#row].text, 1, #row[#row].text - 2) .. ".."
    end

    self.children = rows

    for _, row in ipairs(self.children) do
        local width = 0
        local height = 0
        for _, frag in ipairs(row.formatted) do
            width = width + frag.width
            height = math.max(height, frag.height)
        end
        row:setWidth(width .. "px")
        row:setHeight(height .. "px")
    end
end

-- function TextBox:draw()
--     Box.draw(self)
-- end

local Button = class("Button", Container)

function Button:initialize(str)
    -- self:alignText("center")
    Container.initialize(self)
    self.textBox = self:addChild(TextBox:new(str))
    self.textBox:alignText("center")
    self.textBox:setSize(42)
    self:setWidth("auto")
    self:setHeight("auto")
    self:setAlignContent("center")
    self:setJustifyContent("center")
    self:setTextMargin("20px")
    self.default_bgColor = {0.6, 0.6, 0.6, 1}
    self.pressed_bgColor = {0.3, 0.3, 0.3, 1}
    self.bgColor = self.default_bgColor
    --self:setPadding("20px")
end

function Button:onMousePressed(x, y, click)
    if not self.disabled then
        self.bgColor = self.pressed_bgColor
    end
end

function Button:onMouseReleased(x, y, click)
    self.bgColor = self.default_bgColor
end

function Button:setTextMargin(str)
    self.textBox:setMargin(str)
    return self
end

local Checkbox = class("Checkbox", Box)

function Checkbox:initialize()
    Box.initialize(self)
    self.checked = true
    self:setWidth("20px")
    self:setHeight("20px")
    self.checkColor = {0.3, 0.3, 0.3, 1}
end

function Checkbox:onMousePressed()
    self.checked = not self.checked
end

function Checkbox:draw()
    Box.draw(self)

    if self.checked then
        love.graphics.setColor(unpack(self.checkColor))
        love.graphics.setLineWidth(1)
        love.graphics.line(-self.cPivotX, -self.cPivotY, -self.cPivotX + self.cw, -self.cPivotY + self.ch)
        love.graphics.line(-self.cPivotX + self.cw, -self.cPivotY, -self.cPivotX, -self.cPivotY + self.ch)
        love.graphics.setColor(1, 1, 1, 1)
    end
end


local Slider = class("Slider", Box)

function Slider:initialize()
    Box.initialize(self)
        self:setWidth("300px")
        self:setHeight("20px")
        self.min = 0
        self.max = 100
        self.thumb = 50
        self.bgColor = {0.3, 0.3, 0.3}
        self.thumbColor = {1, 1, 1, 1}
        self.thumbWidth = math.floor(self.max / 10)
        self.thumbScale = 1
        self.thumbSize = self.ch * self.thumbScale
        self.thumbX = 1
        self.thumbY = 1
        self.mouseDown = false
        self.thumbHovered = false
end

function Slider:update(dt)
    self.thumbSize = self.ch * self.thumbScale
    self.thumbX = self.cx + self.thumb * math.floor(self.cw / self.max + 0.5) - math.floor(self.thumbSize / 2 + 0.5)
    self.thumbY = self.cy + math.floor(self.ch / 2 + 0.5) - math.floor(self.thumbSize / 2 + 0.5)

    if self.mouseDown then self.thumbScale = 1.3 else self.thumbScale = 1 end
end

function Slider:draw()
    Box.draw(self)
    -- love.graphics.setColor(unpack(self.bgColor))
    -- love.graphics.rectangle('fill', self.cx, self.cy, self.cw, self.ch)
    love.graphics.setColor(unpack(self.thumbColor))
    love.graphics.rectangle('fill', self.thumbX - self.cx - self.cPivotX, self.thumbY - self.cy - self.cPivotY, self.thumbSize, self.thumbSize)
end


function Slider:resize()
    -- calc thumbPos
    self.thumb = math.max(0, math.min(self.thumb + 2, self.max))
end


function Slider:onMouseMoved(x, y)
    if x > self.thumbX and x < self.thumbX + self.thumbSize and
       y > self.thumbY and y < self.thumbY + self.thumbSize then
        self.thumbHovered = true
    else
        self.thumbHovered = false
    end

    if x > self.cx and x < self.cx + self.cw and
       y > self.cy and y < self.cy + self.ch then
        self.barHovered = true
    else
        self.barHovered = false
    end

    if self.mouseDown then
        self.thumb = math.max(0, math.min((x - self.cx + 0.5) / math.floor(self.cw / self.max + 0.5), self.max))
    end
end

function Slider:onMousePressed(x, y)
    if x > self.thumbX and x < self.thumbX + self.thumbSize and
       y > self.thumbY and y < self.thumbY + self.thumbSize then
        self.mouseDown = true
       end
end

function Slider:onMouseReleased(x, y)
    self.mouseDown = false
end

function Slider:wheelMoved(x, y)
    if not self.mouseDown then
        if self.barHovered then
            if y < 0 then
                self.thumb = math.max(0, math.min(self.thumb + 2, self.max))
            elseif y > 0 then
                self.thumb = math.max(0, math.min(self.thumb - 2, self.max))
            end
        end
    end
end


local Input = class("Input", Container)

function Input:initialize()
    Container.initialize(self)

    self:setWidth("300px")
    self:setHeight("50px")

    self.text = ""
    self.cursor = "_"
    self.cursorPos = 1
    self.isFocused = true
    self:setAlignContent("center")
    self.textBox = self:addChild(TextBox:new())
        :setMargin("5px")
        :setJustifyContent("space-around")
        :setWidth("100%")
        :setHeight("100%")

        self.textBox.bgColor = {1, 1, 1}

    self.bgColor = {0.6, 0.6, 0.6}
end

function Input:insertChar(key)
    self.text = self.text .. key
    self.cursorPos = self.cursorPos + 1
end

function Input:erase()
    -- local temp = self.text
    if #self.text > 0 then
        self.text = string.sub(self.text, 0, self.cursorPos - 1) .. string.sub(self.text, self.cursorPos + 1, #self.text)
    end
    self.cursorPos = math.max(1, self.cursorPos - 1)
end

function Input:keyPressed(key)
    if self.isFocused then
        if key == "backspace" then
            self:erase()
            self.textBox:setText(self.text)
        end

        local char

        if key == "space" then
            char = " "
        end

        if key == "tab" then
            char = "    "
        end

        if key == "return" then
            self:onSubmit()
        end

        if #key == 1 then
            local charCode = string.byte(key, 1, 1)
            if charCode and charCode >= 32 and charCode <= 126 then
                char = key
            end
        end

        if char then
            self:insertChar(char)

            self.textBox:setText(self.text)
            self:_applyRowStyles()
        end
    end
end

function Input:_applyRowStyles()
    for index, row in ipairs(self.textBox.children) do
        row:setMargin("auto", "right")
    end
end


local ImageBox = class("ImageBox", Box)

function ImageBox:initialize(path)
    Box.initialize(self)

    self.image = love.graphics.newImage(path)
    self.origWidth, self.origHeight = self.image:getDimensions()
    self:setWidth(self.origWidth .. "px")
    self:setHeight(self.origHeight .. "px")
    self.bgColor = nil
    self.scaleBy = nil
end

function ImageBox:setScale()
    -- self:setWidth(w .. "px")
    -- self:setHeight(h .. "px")
    self.scaleX = self.cw / self.origWidth
    self.scaleY = self.ch / self.origHeight
end

function ImageBox:resize()
    Box.resize(self)

    self:setScale()
end

function ImageBox:_handleAspectRatio(w, h)

    if self.scaleBy == SCALE_BY.HEIGHT then
        local ratio = self.origHeight / self.origWidth
        return h * ratio, h

    elseif self.scaleBy == SCALE_BY.WIDTH then
        local ratio = self.origHeight / self.origWidth
        return w, w * ratio
    end

    return w, h
end

function ImageBox:setScaleBy(str)
    assert(type(str) == "string", "Argument must be a string!")
    -- add a check for SCALE_BY values
    self.scaleBy = str
    return self
end


function ImageBox:draw()
    -- love.graphics.push()
    -- love.graphics.rotate(self.tr)
    -- love.graphics.scale(self.tsx, self.tsy)
    Box.draw(self) -- Draws background if needed
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.image, -self.cPivotX, -self.cPivotY, 0, self.scaleX, self.scaleY)
    -- love.graphics.pop()
end


local QuadBox = class("QuadBox", Box)

function QuadBox:initialize(texture, x, y, w, h)
    Box.initialize(self)

    self.texture = texture
    self.origWidth, self.origHeight = w, h
    self.quad = love.graphics.newQuad(x, y, w, h, texture)
    self:setWidth(self.origWidth .. "px")
    self:setHeight(self.origHeight .. "px")
    self.bgColor = nil
    self.scaleBy = nil

    self.texture:setWrap("clamp", "clamp")
end

function QuadBox:setScale()
    -- self:setWidth(w .. "px")
    -- self:setHeight(h .. "px")
    self.scaleX = self.cw / self.origWidth
    self.scaleY = self.ch / self.origHeight
end

function QuadBox:resize()
    Box.resize(self)
    self:setScale()
end

function QuadBox:_handleAspectRatio(w, h)

    if self.scaleBy == SCALE_BY.HEIGHT then
        local ratio = self.origHeight / self.origWidth
        return h * ratio, h

    elseif self.scaleBy == SCALE_BY.WIDTH then
        local ratio = self.origHeight / self.origWidth
        return w, w * ratio
    end

    return w, h
end

function QuadBox:setScaleBy(str)
    assert(type(str) == "string", "Argument must be a string!")
    -- add a check for SCALE_BY values
    self.scaleBy = str
    return self
end

function QuadBox:draw()
    Box.draw(self) -- Draws background if needed
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.texture, self.quad, -self.cPivotX, -self.cPivotY, 0, self.scaleX, self.scaleY)
end



local AnimatedQuadBox = class("AnimatedQuadBox", QuadBox)

function AnimatedQuadBox:initialize(texture)
    QuadBox.initialize(self, texture, nil)
    self.animations = {}
    self.currentAnimation = nil
    self.timer = 0
    self.reverse = false
    self.playing = false
    self.autoplay = true
end

function AnimatedQuadBox:addAnimation(name, frameTime, frames, reverse, oneshot)
    self.animations[name] = {
        frameTime = frameTime or 0.1,
        frames = frames or {},  -- A list of quads
        reverse = reverse or false,
        oneshot = oneshot or false,  -- Whether the animation is a oneshot
        currentFrame = 1,
        timer = 0,
        playing = false
    }
end

function AnimatedQuadBox:setAnimation(name, autoplay)
    local animation = self.animations[name]
    assert(animation, "Animation '" .. name .. "' not found")

    self.currentAnimation = name
    self.quad = animation.frames[1]
    self.timer = 0
    self.playing = true
    animation.currentFrame = 1
    animation.timer = 0

    self.autoplay = autoplay == nil and true or autoplay
    if self.autoplay then
        animation.playing = true
    else
        animation.playing = false
    end
end

function AnimatedQuadBox:addFrameToAnimation(animationName, x, y, w, h)
    local animation = self.animations[animationName]
    assert(animation, "Animation '" .. animationName .. "' not found")

    local quad = love.graphics.newQuad(x, y, w, h, self.texture.origWidth, self.texture.origHeight)
    table.insert(animation.frames, quad)
end

function AnimatedQuadBox:play()
    if self.currentAnimation then
        self.animations[self.currentAnimation].playing = true
    end
end

function AnimatedQuadBox:pause()
    if self.currentAnimation then
        self.animations[self.currentAnimation].playing = not self.animations[self.currentAnimation].playing
    end
end

function AnimatedQuadBox:stop()
    if self.currentAnimation then
        self.animations[self.currentAnimation].playing = false
        self.animations[self.currentAnimation].timer = 0
        self.quad = self.animations[self.currentAnimation].frames[1]
    end
end

function AnimatedQuadBox:setReverse(state)
    if self.currentAnimation then
        self.animations[self.currentAnimation].reverse = state
    end
end

function AnimatedQuadBox:update(dt)
    if self.currentAnimation and self.animations[self.currentAnimation] then
        local animation = self.animations[self.currentAnimation]

        -- if #animation.frames == 1 and self.quad ~= animation.frames[1] then
        --     self.quad = animation.frames[1]
        --     return
        -- end

        if not animation.playing then return end

        animation.timer = animation.timer + dt
        if animation.timer >= animation.frameTime then
            animation.timer = animation.timer - animation.frameTime
            if animation.reverse then
                animation.currentFrame = (animation.currentFrame - 2) % #animation.frames + 1
            else
                animation.currentFrame = animation.currentFrame % #animation.frames + 1
            end
            self.quad = animation.frames[animation.currentFrame]

            -- Handle oneshot animation
            if animation.oneshot and animation.currentFrame == #animation.frames then
                animation.playing = false
            end
        end
    end
end


return {
    Box = Box,
    Container = Container,
    TextBox = TextBox,
    Button = Button,
    Checkbox = Checkbox,
    Slider = Slider,
    Input = Input,
    ImageBox = ImageBox,
    QuadBox = QuadBox,
    AnimatedQuadBox = AnimatedQuadBox,


    TYPE = TYPE,
    UNIT_TYPES = UNIT_TYPES,
    POSITION_TYPES = POSITION_TYPES,
    FLEX_JUSTIFY = FLEX_JUSTIFY,
    FLEX_ALIGN = FLEX_ALIGN,
    FLEX_DIRECTION = FLEX_DIRECTION,
    OVERFLOW = OVERFLOW,
    SCALE_BY = SCALE_BY,
}