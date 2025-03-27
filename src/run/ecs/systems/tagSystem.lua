local Concord = require("libs.concord")
local tags = require "src.generation.tags"

local tagSystem = Concord.system({pool = {tag, position}})

function tagSystem:init()
    self.tags = {}
end

function tagSystem:applyTag(entity, tagType, source)
    local tag = tags[tagType]
        -- create it
    if tag then

        -- use entity factory

        table.insert(source.tag.tags, m)

        -- Trigger onApply event for the tag
        if tag.onApply then
            tag.onApply(entity)
        end
    end
end


function tagSystem:onStandBy()
    for _, tag in ipairs(self.pool) do
        if not tag.duration then
            return
        end

        if tag.turn > tag.duration then
            if tags[tag.name].onExpire then
                tag.onExpire(tag.entity)
            end

            self:removeTag(tag)
        else
            tag.turn = tag.turn + 1
        end
    end
end

function tagSystem:removeTag(tag)
    for i, m in ipairs(tag.source.tags) do
        if m == tag then
            table.remove(tag.source.tags, i) 
            break
        end
    end
end

-- we can find marks in any passive: animal, item


-- Trigger onProc when tag is triggered (can be called when the tag effect triggers)
function tagSystem:triggerProc(entity, tagSype)
    for _, tagData in ipairs(self.tags) do
        if tagData.entity == entity and tagData.type == tagSype then
            local tag = tags[tagData.type]
            if tag and tag.onProc then
                tag.onProc(entity)
            end
            break
        end
    end
end

return tagSystem
