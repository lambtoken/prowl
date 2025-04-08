local tween = require "libs.tween"
local RM = require ("src.render.RenderManager"):getInstance()
local GameState = require ("src.state.GameState"):getInstance()

TextBubbleManager = {}
TextBubbleManager.__index = TextBubbleManager

function TextBubbleManager:new()
    local o = {
        ccShort = {},
        ccLong = {},
        damage = {},
        statusEffects = {},
        deltaTimeWobble = nil,
        wobbleFrequency = 2,
        wobbleRange = 1.3,
        world = nil  -- Will be set when the manager is created
    }
    setmetatable(o, self)
    o.__index = self

    return o
end

TextBubble = {}
TextBubble.__index = TextBubble

function TextBubble:newShortCC(entity, text)
    local o = {
        entityId = entity.metadata.id,  -- Store entity ID instead of reference
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
        entityId = entity.metadata.id,  -- Store entity ID instead of reference
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
        entityId = entity.metadata.id,  -- Store entity ID instead of reference
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

function TextBubble:newStatusEffect(entity, text, duration)
    local o = {
        entityId = entity.metadata.id,  -- Store entity ID instead of reference
        text = text,
        textWidth = getFont("basis33", 16):getWidth(text),
        textHeight = getFont("basis33", 16):getHeight(),
        x = 0,
        y = 0,
        baseX = 0,
        baseY = 0,
        duration = duration or 999999,
        timer = 0,
        alpha = 1,
        floatAmplitude = RM.tileSize / 2,
        floatFrequencyX = math.random() * 0.5 + 0.8,
        floatFrequencyY = math.random() * 0.5 + 0.6,
        color = {1, 1, 1},
        bubbleRangeX = 20,
        bubbleRangeY = 20,
        floatDurationX = math.random() * 0.3 + 2,
        floatDurationY = math.random() * 0.3 + 2,
        id = tostring(os.time()) .. tostring(math.random(1000, 9999)) -- Unique ID for each bubble
    }

    -- print(entity.metadata.id)
    -- print(entity.metadata.species)
    -- print(o.entityId)

    o.tweenX = tween.new(o.floatDurationX, o, {x = o.bubbleRangeX}, "inOutQuart")
    o.tweenY = tween.new(o.floatDurationY, o, {y = o.bubbleRangeY}, "inOutQuart")
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
        end

        bubble.timer = bubble.timer + dt
        ::continue::
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
        ::continue::
    end

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
        ::continue::
    end
    
    -- handle status effect bubbles
    for i = #self.statusEffects, 1, -1 do
        local bubble = self.statusEffects[i]

        -- different frequency for x and y
        local angleX = bubble.timer * bubble.floatFrequencyX
        local angleY = bubble.timer * bubble.floatFrequencyY
        local offset = RM.tileSize / 2
        
        bubble.x = math.sin(angleX) * bubble.floatAmplitude + bubble.baseX + offset - bubble.textWidth
        bubble.y = math.cos(angleY) * bubble.floatAmplitude + bubble.baseY + offset - bubble.textHeight

        if bubble.kill then
            bubble.alpha = bubble.alpha - dt
            if bubble.alpha <= 0 then
                table.remove(self.statusEffects, i)
            end
        end

        bubble.timer = bubble.timer + dt
        ::continue::
    end
end

function TextBubbleManager:newBubble(type, entity, arg, crit)
   
    if type == "damage" then
        table.insert(self.damage, TextBubble:newDamage(entity, arg, crit))
    elseif type == "shortCC" then
        table.insert(self.ccShort, TextBubble:newShortCC(entity, arg))
    elseif type == "longCC" then
        table.insert(self.ccLong, TextBubble:newLongCC(entity, arg))
    elseif type == "statusEffect" then
        
        for _, bubble in ipairs(self.statusEffects) do
            if bubble.text == arg and bubble.entityId == entity.metadata.id then
                bubble.duration = bubble.duration + 1
                return bubble.id
            end
        end

        local bubble = TextBubble:newStatusEffect(entity, arg)
        table.insert(self.statusEffects, bubble)
        return bubble.id -- Return the bubble ID
    end
end

function TextBubbleManager:endLongCC(bubble)
    bubble.kill = true
end

function TextBubbleManager:endStatusEffect(bubbleId)
    if not bubbleId then
        print("Warning: Attempted to end status effect with nil bubbleId")
        return
    end
    
    local found = false
    for i = #self.statusEffects, 1, -1 do
        local bubble = self.statusEffects[i]
        if bubble.id == bubbleId then
            bubble.kill = true
            found = true
            break
        end
    end
    
    if not found then
        -- Bubble might have already been removed
        print("Note: No bubble found with ID " .. bubbleId .. " - may have already been removed")
    end
end


function TextBubbleManager:draw()
    local r, g, b
    for _, bubble in ipairs(self.damage) do
        if not bubble.entityRef then
            bubble.entityRef = GameState.currentMatch:getEntityById(bubble.entityId)
        end

        if bubble.entityRef and bubble.alpha > 0 then
            r, g, b = unpack(bubble.color)
            love.graphics.setColor(r, g, b, bubble.alpha)
            love.graphics.print(bubble.amount, bubble.x + bubble.entityRef.position.screenX + bubble.offsetX, bubble.y + bubble.entityRef.position.screenY)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    for _, bubble in ipairs(self.ccShort) do
        if not bubble.entityRef then
            bubble.entityRef = GameState.currentMatch:getEntityById(bubble.entityId)
        end

        if bubble.entityRef and bubble.alpha > 0 then
            love.graphics.setColor(1, 1, 1, 1)
            r, g, b = unpack(bubble.color)
            love.graphics.setColor(r, g, b, bubble.alpha)
            love.graphics.print(bubble.text, bubble.x + bubble.entityRef.position.screenX + bubble.offsetX, bubble.y + bubble.entityRef.position.screenY)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    for _, bubble in ipairs(self.statusEffects) do
        
        if not bubble.entityRef then
            bubble.entityRef = GameState.currentMatch:getEntityById(bubble.entityId)
        end

        if bubble.entityRef and bubble.alpha > 0 then
            love.graphics.setColor(1, 1, 1, bubble.alpha)
            love.graphics.print(bubble.text, bubble.x + bubble.entityRef.position.screenX, bubble.y + bubble.entityRef.position.screenY)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function TextBubbleManager:killEntityBubbles(entity)
    if not entity or not entity.metadata then
        print("Warning: Attempted to kill bubbles for nil entity or entity without metadata")
        return {}
    end
    
    local entityId = entity.metadata.id
    print("killing entity bubbles", entityId)
    local removedBubbleIds = {}

    -- Kill damage bubbles
    for _, bubble in ipairs(self.damage) do
        if bubble.entityId == entityId then
            bubble.kill = true
        end
    end

    -- Kill short CC bubbles
    for _, bubble in ipairs(self.ccShort) do
        if bubble.entityId == entityId then
            bubble.kill = true
        end
    end

    -- Kill long CC bubbles
    for _, bubble in ipairs(self.ccLong) do
        if bubble.entityId == entityId then
            bubble.kill = true
        end
    end

    -- Kill status effect bubbles
    for _, bubble in ipairs(self.statusEffects) do
        if bubble.entityId == entityId then
            print("killing status effect bubble", entityId, bubble.entityId)
            bubble.kill = true
            -- Add the bubble ID to the removed list
            table.insert(removedBubbleIds, bubble.id)
        end
    end
    
    return removedBubbleIds
end

return TextBubbleManager