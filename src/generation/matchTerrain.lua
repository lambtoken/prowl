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
            board.terrain[i][j] = Tile:new('floor', 'ground', true)
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


return terrain