local function getAutoTileIndex(grid, x, y)
    local index = 0
    
    for i = -1, 1 do
        for j = -1, 1 do
            local nx, ny = x + i, y + j
            if grid[ny] and grid[ny][nx] then
                if grid[ny][nx].type == 'wall' then
                    index = index + 2^(3 - i + 3*(1 - j))
                end
            end
        end
    end
    
    return index
end

local autoTile = function(terrain)

    for i = 1, #terrain[1] do
        for j = 1, #terrain do
            local tile = terrain[j][i]

            if tile.type == 'wall' then
                terrain[j][i].spriteName = terrain[j][i].type .. tostring(getAutoTileIndex(terrain, i, j))
            end
        end
    end

end

return autoTile