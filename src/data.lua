local data = {
    animals = {
        {
            key = 'cat',
            name = 'cat',
            unlocked = true
        },
        {
            key = 'chicken',
            name = 'chicken',
            unlocked = true
        },
        {
            key = 'rat',
            name = 'rat',
            unlocked = true
        },
        {
            key = 'duck',
            name = 'duck',
            unlocked = true
        },
        {
            key = 'spider',
            name = 'spider',
            unlocked = false
        },
        {
            key = 'deer',
            name = 'deer',
            unlocked = false
        },
        {
            key = 'turtle',
            name = 'turtle',
            unlocked = false
        },
        {
            key = 'axolotl',
            name = 'axolotl',
            unlocked = false
        },
        {
            key = 'crow',
            name = 'crow',
            unlocked = false
        },
        {
            key = 'snake',
            name = 'snake',
            unlocked = false
        },
        {
            key = 'bat',
            name = 'bat',
            unlocked = false
        },
        {
            key = 'bull',
            name = 'bull',
            unlocked = false
        },
        {
            key = 'rabbit',
            name = 'rabbit',
            unlocked = false
        },
        {
            key = 'fox',
            name = 'fox',
            unlocked = false
        },
        {
            key = 'bear',
            name = 'bear',
            unlocked = false
        },
        {
            key = 'polar_bear',
            name = 'polar bear',
            unlocked = false
        },
        {
            key = 'hedgehog',
            name = 'hedgehog',
            unlocked = false
        },
        {
            key = 'crocodile',
            name = 'crocodile',
            unlocked = false
        },
        {
            key = 'camel',
            name = 'camel',
            unlocked = false
        },
        {
            key = 'elephant',
            name = 'elephant',
            unlocked = false
        },
        {
            key = 'giraffe',
            name = 'giraffe',
            unlocked = false
        },
        {
            key = 'lion',
            name = 'lion',
            unlocked = false
        },
        {
            key = 'tiger',
            name = 'tiger',
            unlocked = false
        },
        {
            key = 'bee',
            name = 'bee',
            unlocked = false
        },
        {
            key = 'butterfly',
            name = 'butterfly',
            unlocked = false
        },
        {
            key = 'pig',
            name = 'pig',
            unlocked = false
        },
        {
            key = 'crab',
            name = 'crab',
            unlocked = false
        },
        {
            key = 'wolf',
            name = 'wolf',
            unlocked = false
        },
        {
            key = 'dragon',
            name = 'dragon',
            unlocked = false
        },
        {
            key = 'phoenix',
            name = 'phoenix',
            unlocked = false
        },
        {
            key = 'hydra',
            name = 'hydra',
            unlocked = false
        },
        {
            key = 'wyvern',
            name = 'wyvern',
            unlocked = false
        },
        {
            key = 'magpie',
            name = 'magpie',
            unlocked = false
        },
        {
            key = 'zebra',
            name = 'zebra',
            unlocked = false
        },
        {
            key = 'ram',
            name = 'ram',
            unlocked = false
        },
        {
            key = 'penguin',
            name = 'penguin',
            unlocked = false
        },
        {
            key = 'lizard',
            name = 'lizard',
            unlocked = false
        },
        {
            key = 'snail',
            name = 'snail',
            unlocked = false
        },
        {
            key = 'apple',
            name = 'apple',
            unlocked = true
        }
        
        -- {
        --     key = 'unicorn',
        --     name = 'unicorn',
        --     unlocked = false
        -- },
        -- {
        --     key = 'pegasus',
        --     name = 'pegasus',
        --     unlocked = false
        -- },
        -- {
        --     key = 'griffin',
        --     name = 'griffin',
        --     unlocked = false
        -- },
        
        
        
    }
}

local count = 0
for i, _ in ipairs(data.animals) do
    count = count + 1
end

data.animalCount = count

data.getAnimal = function(name) 

    for i, animal in ipairs(data.animals) do
        if animal.key == name then 
            return animal 
        end
    end

    assert(false, "Animal not found!")
end

data.unlockAllAnimals = function() 
    for i, _ in ipairs(data.animals) do
        _.unlocked = true
    end
end


return data