local Concord = require("libs.concord")
local animalData = require "src.generation.mobs"
local objectData = require "src.generation.objects"
local projectileData = require "src.generation.projectiles"
local tablex     = require "libs.batteries.tablex"
local pretty     = require "libs.batteries.pretty"
local statusDefaults = require "src.run.ecs.defaults.statusDefaults"
local gs = require('src.state.GameState'):getInstance()
local RM = require('src.render.RenderManager'):getInstance()

local EntityFactory = {
    idCounter = 1
}

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
    if comp == "metadata" then
        entity.metadata.id = self.idCounter
        -- print("setting id", entity.metadata.id, entity.metadata.species)
        self.idCounter = self.idCounter + 1
    elseif comp == "stats" then
        if entity.metadata.type == "animal" and animalData[entity.metadata.species].stats then
            
            entity.stats.base = tablex.deep_copy(animalData[entity.metadata.species].stats)

            -- local scalings = {
            --     atk = 1.5,
            --     def = 1,
            --     maxHp = 2
            -- }

            local statGrowth = {
                atk = { flat = 1, every = 3 },     -- +1 atk every 2 levels
                def = { flat = 1, every = 4 },     -- +1 def every 3 levels
                maxHp = { flat = 2, every = 1 },   -- +2 hp every level
            }


            local level = entity.stats.level

            if level > 1 then
                for key, base in pairs(entity.stats.base) do
                    local growth = statGrowth[key]
                    if growth then
                        local amount = math.floor((level - 1) / growth.every) * growth.flat
                        entity.stats.base[key] = base + amount
                    end
                end
            end


            -- negative level might be a way to balance the early matches
            -- if entity.stats.level == -1 then
            --     for key, value in pairs(entity.stats.base) do
            --         if key == "atk" or key == "def" or key == "maxHp" then
                        
            --             local value = math.floor(value / 2 )
                        
            --             if key == "def" then
            --                 value = math.max(0, value)
            --             else
            --                 value = math.max(1, value)  
            --             end

            --             entity.stats.base[key] = value
            --         end
            --     end
            -- end

            -- we need a better and more balanced way to scale the stats
            
            -- if entity.stats.level > 1 then
            --     for key, value in pairs(entity.stats.base) do
            --         if key == "atk" or key == "def" or key == "maxHp" then
            --             entity.stats.base[key] = math.floor(value + scalings[key] ^ (entity.stats.level - 1))
            --             -- entity.stats.base[key] = math.floor((value * 2) / 100) * (entity.stats.level)
            --         end
            --     end
            -- end

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
        elseif entity.metadata.type == "mark" then
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
        elseif entity.metadata.type == "mark" then
            entity.position.isSteppable = true
            entity.position.stepsOn = { "ground" }
        elseif entity.metadata.type == "projectile" then
            entity.position.customMove = projectileData[entity.metadata.projectileType].moveFunction
            entity.position.isSteppable = false
            entity.position.stepsOn = { "ground" }
        elseif entity.metadata.type == "object" and objectData[entity.metadata.objectName].stepsOn then
            entity.position.isSteppable = objectData[entity.metadata.objectName].steppable or false
            if objectData[entity.metadata.objectName].stepsOn then
                entity.position.stepsOn = tablex.deep_copy(objectData[entity.metadata.objectName].stepsOn)
            end
        end
    elseif comp == "collider" then
        if entity.metadata.type == "animal" then
            entity.collider.collisionGroups = {"projectile"}
        elseif entity.metadata.type == "projectile" then
            entity.collider.onCollision = function(source, target)
                local matchState = gs.match
                if target.state and target.state.current == "dead" then
                    return
                end
                projectileData[entity.metadata.projectileType].onHit(matchState, source, target)
                source.position.customMove = nil
            end
            entity.collider.collisionGroups = {"animal"}
        end

        entity.collider.x = (1 - entity.collider.width) / 2
        entity.collider.y = (1 - entity.collider.height) / 2
    end
end

function EntityFactory:createAnimal(species, x, y, level)
    self:loadComponents()
    
    assert(animalData[species], "Species does not exist!")
    if level then
        assert(type(level) == "number", "Level must be a number!")
    end
    
    local entity = Concord.entity()
        :give('metadata', species)
        :give('position', x, y)
        :give('renderable', animalData[species].sprite)
        :give('stats')
        :give('state')
        :give('status')
        :give('crowdControl')
        :give('buffDebuff')
        :give('inventory')
        :give('timers')
        :give('dot')
        :give('collider')
        :give('shader')

    table.insert(entity.shader.shaders, {name = "wobble", uniforms = {}})

    entity.metadata.type = 'animal'
    entity.stats.level = level or 1
    self:applyDefault(entity, 'stats')
    self:applyDefault(entity, 'status')
    self:applyDefault(entity, 'position')
    self:applyDefault(entity, 'metadata')
    self:applyDefault(entity, 'collider')

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
        :give('collider')
        :give('shader')

    entity.metadata.type = 'object'
    entity.metadata.objectName = name
    self:applyDefault(entity, 'status')
    self:applyDefault(entity, 'position')
    self:applyDefault(entity, 'collider')

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
        :give('shader')

    entity.metadata.type = 'flower'
    entity.metadata.subType = 'flower'
    entity.metadata.objectName = name
    self:applyDefault(entity, 'status')
    self:applyDefault(entity, 'position')

    return entity
end

function EntityFactory:createMark(name, x, y)
    self:loadComponents()
    
    local entity = Concord.entity()
        :give('metadata')
        :give('position', x, y)
        :give('renderable', name)
        :give('state')
        :give('status')
        :give('shader')

    table.insert(entity.shader.shaders, {name = "wobble", uniforms = {}})
    
    entity.metadata.type = 'mark'
    entity.metadata.markName = name
    entity.metadata.subType = 'mark'

    self:applyDefault(entity, 'position')
    self:applyDefault(entity, 'status')
    return entity
end

function EntityFactory:createProjectile(type, x, y, targetX, targetY, ownerId)
    self:loadComponents()
    
    -- print("owner id:", ownerId)

    local entity = Concord.entity()
        :give('metadata')
        :give('position', x, y)
        :give('renderable', type)
        :give('projectile')
        :give('collider')
        :give('state')
        :give('shader')

    entity.metadata.type = 'projectile'
    entity.metadata.projectileType = type

    entity.projectile.targetX = targetX
    entity.projectile.targetY = targetY
    entity.projectile.speed = projectileData[type].speed
    entity.projectile.angle = math.atan2(targetY - y, targetX - x)
   
    self:applyDefault(entity, 'position')
    self:applyDefault(entity, 'metadata')
    self:applyDefault(entity, 'collider')
    entity.collider.ignoreIds = ownerId and {ownerId} or {}
    return entity
end

function EntityFactory:reinitializeEntityComponents(entity, ignore)
    self:loadComponents()

    ignore = ignore or {}
    local ignoreSet = {}
    for _, name in ipairs(ignore) do
        ignoreSet[name] = true
    end

    local preserve_level = entity.stats.level
    entity.metadata.type = 'animal'
    entity.stats.level = preserve_level or 1

    for name, _ in pairs(entity) do
        if not ignoreSet[name] and not name:match("^__") then
            local constructorArgs = nil

            -- Special handling for components that need constructor args
            if name == "position" then
                constructorArgs = { entity.position.x, entity.position.y }
            elseif name == "renderable" then
                constructorArgs = { entity.metadata.species }
            elseif name == "metadata" then
                constructorArgs = { entity.metadata.name or entity.metadata.species }
            end

            local componentDef = Concord.components[name]
            if componentDef then
                entity:remove(name)
                pretty.print(constructorArgs)
                if constructorArgs then
                    entity:give(name, unpack(constructorArgs))
                else
                    entity:give(name)
                end

                if self.applyDefault then
                    self:applyDefault(entity, name)
                end
            else
                print("Warning: No component definition found for:", name)
            end
        end
    end
end




return EntityFactory
