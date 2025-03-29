local Concord = require("libs.concord")
local animalData = require "src.generation.mobs"
local objectData = require "src.generation.objects"
local tablex     = require "libs.batteries.tablex"
local pretty     = require "libs.batteries.pretty"
local statusDefaults = require "src.run.ecs.defaults.statusDefaults"

local EntityFactory = {}

function EntityFactory:loadSystems()
    self.__systems = {}
    if #self.__systems == 0 then
        Concord.utils.loadNamespace("src/run/ecs/systems", self.__systems)
    end
    return self.__systems
end

function EntityFactory:loadComponents()
    if not self.componentsLoaded then
        Concord.utils.loadNamespace("src/run/ecs/components")
        self.componentsLoaded = true
    end
end

function EntityFactory:applyDefault(entity, comp)
    if comp == "stats" then
        if entity.metadata.type == "animal" and animalData[entity.metadata.species].stats then
            
            entity.stats.base = tablex.deep_copy(animalData[entity.metadata.species].stats)

            local scalings = {
                atk = 1,
                def = 1,
                maxHp = 2
            }

            -- negative level might be a way to balance the early matches
            if entity.stats.level == -1 then
                for key, value in pairs(entity.stats.base) do
                    if key == "atk" or key == "def" or key == "maxHp" then
                        entity.stats.base[key] = math.floor(value / 2 ) 
                    end
                end
            end

            if entity.stats.level > 1 then
                for key, value in pairs(entity.stats.base) do
                    if key == "atk" or key == "def" or key == "maxHp" then
                        entity.stats.base[key] = value + scalings[key] ^ (entity.stats.level - 1)
                    end
                end
            end
            
            entity.stats.base.hp = entity.stats.base.maxHp
            entity.stats.current = tablex.deep_copy(entity.stats.base)
            entity.stats.basePatterns = {
                movePattern = tablex.deep_copy(animalData[entity.metadata.species].movePattern),
                atkPattern = tablex.deep_copy(animalData[entity.metadata.species].atkPattern)
            }
            entity.stats.currentPatterns = {
                movePattern = tablex.deep_copy(animalData[entity.metadata.species].movePattern),
                atkPattern = tablex.deep_copy(animalData[entity.metadata.species].atkPattern)
            }
        end
    elseif comp == "status" then
        local defaults = statusDefaults

        local default = tablex.deep_copy(defaults)

        if entity.metadata.type == "animal" and animalData[entity.metadata.species].status then
            for key, value in pairs(animalData[entity.metadata.species].status) do
                default[key] = value
            end
        elseif entity.metadata.type == "flower" then
            default.isTargetable = false
            default.isDisplaceable = false
        elseif entity.metadata.type == "object" and objectData[entity.metadata.objectName].status then
            for key, value in pairs(objectData[entity.metadata.objectName].status) do
                default[key] = value
            end            
        end

        entity.status.current = default

    elseif comp == "position" then

        if entity.metadata.type == "animal" and animalData[entity.metadata.species].stepsOn then
            entity.position.isSteppable = false
            if animalData[entity.metadata.species].stepsOn then
                entity.position.stepsOn = tablex.deep_copy(animalData[entity.metadata.species].stepsOn)
            end
        elseif entity.metadata.type == "flower" then
            entity.position.isSteppable = true
            entity.position.stepsOn = { "ground" }
        elseif entity.metadata.type == "object" and objectData[entity.metadata.objectName].stepsOn then
            entity.position.isSteppable = objectData[entity.metadata.objectName].steppable or false
            if objectData[entity.metadata.objectName].stepsOn then
                entity.position.stepsOn = tablex.deep_copy(objectData[entity.metadata.objectName].stepsOn)
            end
        end
    end
end

function EntityFactory:createAnimal(species, x, y, level)
    self:loadComponents()
    assert(animalData[species], "Species does not exist!")
    if level then
        assert(type(level) == "number", "Level must be a number!")
        -- assert(level > 0 and level <= 3, "Level is too large or too small!")
        -- assert(level > 0, "Level provided is " .. level .. ", should be a positive intiger!")
    end
    
    local entity = Concord.entity()
        :give('metadata', species)
        :give('position', x, y)
        :give('renderable', animalData[species].sprite)
        :give('stats')
        :give('state')
        :give('status')
        :give('crowdControl')
        :give('inventory')
        :give('timers')

    entity.metadata.type = 'animal'
    entity.stats.level = level or 1
    self:applyDefault(entity, 'stats')
    self:applyDefault(entity, 'status')
    self:applyDefault(entity, 'position')

    return entity
end

function EntityFactory:createObject(name, x, y)
    self:loadComponents()
    assert(objectData[name], "Object does not exist!")
    
    local entity = Concord.entity()
        :give('metadata')
        :give('position', x, y)
        :give('renderable', objectData[name].sprite)
        :give('state')
        :give('status')
        :give('crowdControl')
        :give('timers')

    entity.metadata.type = 'object'
    entity.metadata.objectName = name
    self:applyDefault(entity, 'status')
    self:applyDefault(entity, 'position')

    return entity
end

function EntityFactory:createFlower(name, x, y)
    self:loadComponents()
    
    local entity = Concord.entity()
        :give('metadata')
        :give('position', x, y)
        :give('renderable', name)
        :give('state')
        :give('status')
        :give('timers')
        :give('crowdControl')

    entity.metadata.type = 'flower'
    entity.metadata.subType = 'flower'
    entity.metadata.objectName = name
    self:applyDefault(entity, 'status')
    self:applyDefault(entity, 'position')


    return entity
end

return EntityFactory
