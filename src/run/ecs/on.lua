local mobData = require "src.generation.mobs"
local itemData = require "src.generation.items"
local objectData = require "src.generation.objects"

local function on(callback, matchState, entity, ...)
    local args = {...}  -- Capture all variable arguments into a table
    local itemArgPos = nil
    
    if entity.metadata.type == 'animal' then
        local animal = mobData[entity.metadata.name]
        if animal.passive and animal.passive[callback] then
            animal.passive[callback](matchState, entity, ...)
        end
        if entity.inventory and entity.inventory.items then
            for _, item in ipairs(entity.inventory.items) do
                local itemDef = itemData[item.name]
                if itemDef.passive and itemDef.passive[callback] then
                    if item.cooldowns and item.cooldowns[callback] and item.cooldowns[callback] > 0 then
                        goto continue
                    end
                    
                    -- Create new arguments table with item last
                    local newArgs = {matchState, entity}
                    for _, v in ipairs(args) do
                        table.insert(newArgs, v)
                    end
                    table.insert(newArgs, item)
                    
                    itemDef.passive[callback](unpack(newArgs))
                end
                ::continue::
            end
        end
    end

    if entity.metadata.type == 'object' then
        local object = objectData[entity.metadata.name]
        if object.passive and object.passive[callback] then
            object.passive[callback](matchState, entity, ...)
        end
    end
end

return on