local Tile = require "src.run.Tile"

local terrain = {
    -- forest = "grass",
    -- dungeon = "floor",
    -- arena = "floor",
    -- desert = "sand",
    -- jungle = "tall_grass",
}

terrain.forest = {}

function terrain.forest.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('grass', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('grass_patchy', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('grass_ghost_flowers', 'ground', true) end
            -- board.objects[i][j] = math.random() > 0.8 and Tile:new(math.random() > 0.5 and 'spruce_tree' or 'oak_tree', false) or nil
        end
    end

    return board
end

function terrain.forest.gloam(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('gloam_grass', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('gloam_grass_patchy', true) end
            -- if math.random() > 0.9 then board.terrain[i][j] = Tile:new('gloam_grass_ghost_flowers', true) end
            -- if math.random() > 0.9 then board.objects[i][j] = Tile:new('starlite_flowers', true) end
            -- if math.random() > 0.95 then board.objects[i][j] = Tile:new('starlite_flowers2', true) end
        end
    end

    return board
end

terrain.desert = {}

function terrain.desert.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('sand', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('sand_checkers', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('sand_waves', 'ground', true) end
        end
    end

    return board
end

terrain.dungeon = {}

function terrain.dungeon.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do

            local decoratedChance = math.random()

            if decoratedChance < 0.3 then
                local r = math.random()

                if r < 0.15 then
                    board.terrain[i][j] = Tile:new('cobble1', 'ground', true)
                elseif r < 0.30 then
                    board.terrain[i][j] = Tile:new('cobble2', 'ground', true)
                elseif r < 0.45 then
                    board.terrain[i][j] = Tile:new('cobble3', 'ground', true)
                elseif r < 0.60 then
                    board.terrain[i][j] = Tile:new('bricks1', 'ground', true)
                elseif r < 0.75 then
                    board.terrain[i][j] = Tile:new('bricks2', 'ground', true)
                else
                    board.terrain[i][j] = Tile:new('bricks3', 'ground', true)
                end
            else
                board.terrain[i][j] = Tile:new('floor', 'ground', true)
            end
        end
    end

    return board
end

terrain.arena = {}

function terrain.arena.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('floor', 'ground', true)
        end
    end

    return board
end

terrain.glacial = {}

function terrain.glacial.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('snow', 'ground', true)
        end
    end

    return board
end

terrain.plains = {}

function terrain.plains.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('grass_light', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('grass_light_patchy', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('grass_light_flowers', 'ground', true) end
        end
    end

    return board
end

terrain.dragon = {}

function terrain.dragon.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('floor', 'ground', true)
        end
    end

    return board
end

terrain.phoenix = {}

function terrain.phoenix.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('floor', 'ground', true)
        end
    end

    return board
end

terrain.hydra = {}

function terrain.hydra.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('floor', 'ground', true)
        end
    end

    return board
end

terrain.swamp = {}

function terrain.swamp.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('swamp_grass', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('swamp_grass_patchy', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('swamp_grass_flowers', 'ground', true) end
        end
    end

    return board
end

terrain.beach = {}

function terrain.beach.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('sand', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('sand_checkers', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('sand_waves', 'ground', true) end
        end
    end

    return board
end

terrain.savannah = {}

function terrain.savannah.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('savannah', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('savannah_checkers', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('savannah_waves', 'ground', true) end
        end
    end

    return board
end

terrain.meadow = {}

function terrain.meadow.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('meadow_grass', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('meadow_grass_patchy', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('meadow_grass_flowers', 'ground', true) end
        end
    end

    return board
end

terrain.cave = {}

function terrain.cave.normal(width, height)
    local board = {}
    board.terrain = {}
    board.decoration = {}

    for i = 1, height do
        board.terrain[i] = {}
        for j = 1, width do
            board.terrain[i][j] = Tile:new('cave_floor', 'ground', true)
            if math.random() > 0.8 then board.terrain[i][j] = Tile:new('cave_floor_stones', 'ground', true) end
            if math.random() > 0.9 then board.terrain[i][j] = Tile:new('cave_floor_mossy', 'ground', true) end
        end
    end

    return board
end

return terrain
