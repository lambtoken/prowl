local tween = require "libs.tween"

TextBubbleManager = {}
TextBubbleManager.__index = TextBubbleManager

function TextBubbleManager:new()
    local o = {
        ccShort = {},
        ccLong = {},
        damage = {},
        deltaTimeWobble = nil,
        wobbleFrequency = 2,
        wobbleRange = 1.3
    }
    setmetatable(o, self)
    o.__index = self

    return o
end

TextBubble = {}
TextBubble.__index = TextBubble

function TextBubble:newShortCC(entity, text)
    local o = {
        entity = entity,
        text = text,
        x = 0,
        y = 0,
        baseX = 0,
        baseY = 0,
        duration = 2,
        timer = 0,
        alpha = 1,
        floatAmplitude = 5,
        floatFrequency = 1,
        color = {1, 1, 1}
    }

    o.floatFrequencyX = o.floatFrequency - math.random() * 0.4
    o.offsetX = math.random(30) - 15
    
    setmetatable(o, self)
    o.__index = self
    return o
end


function TextBubble:newLongCC(entity, text)
    local o = {
        entity = entity,
        text = text,
        x = 0,
        y = 0,
        baseY = y,
        baseX = x,
        duration = 2,
        alpha = 1,
        floatAmplitude = 5,
        floatFrequency = 1,
        bubbleRangeX = 20,
        bubbleRangeY = 20,
        floatDurationX = math.random() * 0.3 + 2,
        floatDurationY = math.random() * 0.3 + 2,
        color = {1, 1, 1}
    }

    o.tweenX = tween.new(o.floatDurationX, o, {x = o.bubbleRangeX}, "inOutQuart")
    o.tweenY = tween.new(o.floatDurationY, o, {y = o.bubbleRangeY}, "inOutQuart")
    
    setmetatable(o, self)
    o.__index = self
    return o
end


function TextBubble:newDamage(entity, amount, crit)
    local o = {
        entity = entity,
        amount = tostring(amount),
        x = 0,
        y = 0,
        baseY = y,
        baseX = x,
        offsetX = 0,
        duration = 2,
        timer = 0,
        alpha = 1,
        fallDistance = 20,
        fallDuration = 2,
        color = crit and {1, 0, 0} or {1, 1, 1}
    }

    o.tweenY = tween.new(o.fallDuration, o, {y = o.fallDistance}, "inOutQuart")
    
    setmetatable(o, self)
    o.__index = self
    return o
end


function TextBubbleManager:update(dt)
    -- handle short bubbles
    for i = #self.ccShort, 1, -1 do
        local bubble = self.ccShort[i]

        if bubble.timer < bubble.duration then
            
            bubble.y = bubble.baseY + math.sin(bubble.timer * bubble.floatFrequency * math.pi) * bubble.floatAmplitude
            bubble.x = bubble.baseX + math.sin(bubble.timer * bubble.floatFrequencyX * math.pi) * bubble.floatAmplitude
            
            bubble.alpha = 1 - (bubble.timer / bubble.duration)
            
            bubble.floatAmplitude = bubble.floatAmplitude + 0.01
        else
            bubble.alpha = 0
        end
        
        if bubble.alpha <= 0 then
            table.remove(self.ccShort, i)
            print("deleted")
        end

        bubble.timer = bubble.timer + dt
    end


    -- handle damage bubbles
    for i = #self.damage, 1, -1 do
        local bubble = self.damage[i]

        if bubble.timer < bubble.duration then
            
            bubble.tweenY:update(dt)
            bubble.alpha = 1 - (bubble.timer / bubble.duration)

        else
            bubble.alpha = 0
        end
        
        if bubble.alpha <= 0 then
            table.remove(self.damage, i)
        end

        bubble.timer = bubble.timer + dt
    end


    -- this dt hack creates variation in speed
    self.deltaTimeWobble = math.sin(love.timer.getTime() * self.wobbleFrequency * math.pi) * self.wobbleRange
    dt = dt * self.deltaTimeWobble


    -- handle longer ones
    for i = #self.ccLong, 1, -1 do
        local bubble = self.ccLong[i]

        if bubble.tweenX:update(dt) then
            bubble.tweenX.target.x = bubble.tweenX.target.x == bubble.bubbleRangeX and 0 or bubble.bubbleRangeX
        end
        
        if bubble.tweenY:update(dt) then
            bubble.tweenY.target.y = bubble.tweenX.target.y == bubble.bubbleRangeY and 0 or bubble.bubbleRangeY
        end

        if bubble.kill then
            bubble.alpha = 1 - (bubble.timer / bubble.duration)
            if bubble.alpha <= 0 then
                table.remove(self.ccLong, i)
            end
        end
    end
    
end


function TextBubbleManager:newBubble(type, entity, arg, crit)

    if type == "damage" then
        table.insert(self.damage, TextBubble:newDamage(entity, arg, crit))
    elseif type == "shortCC" then
        table.insert(self.ccShort, TextBubble:newShortCC(entity, arg))
    elseif type == "longCC" then
    
    end
end


function TextBubbleManager:endLongCC(bubble)
    bubble.kill = true
end


function TextBubbleManager:draw()
    local r, g, b
    for _, bubble in ipairs(self.damage) do
        if bubble.alpha > 0 then
            r, g, b = unpack(bubble.color)
            love.graphics.setColor(r, g, b, bubble.alpha)
            love.graphics.print(bubble.amount, bubble.x + bubble.entity.position.screenX + bubble.offsetX, bubble.y + bubble.entity.position.screenY)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    for _, bubble in ipairs(self.ccShort) do
        if bubble.alpha > 0 then
            love.graphics.setColor(1, 1, 1, 1)
            r, g, b = unpack(bubble.color)
            love.graphics.setColor(r, g, b, bubble.alpha)
            love.graphics.print(bubble.text, bubble.x + bubble.entity.position.screenX + bubble.offsetX, bubble.y + bubble.entity.position.screenY)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end


return TextBubbleManager