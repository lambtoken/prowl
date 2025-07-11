-- returns true if all points in 'goals' are reachable from 'start' given a set of blocked positions
-- blocked: set of [x][y]=true
-- width, height: board size
-- neighbours: function(x, y) -> list of {x, y} adjacent positions
local function is_fully_connected(start, goals, blocked, width, height)
    local function node_key(x, y) return x .. "," .. y end
    local visited = {}
    local function neighbours(node)
        local x, y = node[1], node[2]
        local nbs = {}
        for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
            local nx, ny = x + d[1], y + d[2]
            if nx >= 0 and nx < width and ny >= 0 and ny < height and not (blocked[nx] and blocked[nx][ny]) then
                table.insert(nbs, {nx, ny})
            end
        end
        return nbs
    end

    -- BFS from start
    local queue = {start}
    visited[node_key(start[1], start[2])] = true
    while #queue > 0 do
        local node = table.remove(queue, 1)
        for _, nb in ipairs(neighbours(node)) do
            local k = node_key(nb[1], nb[2])
            if not visited[k] then
                visited[k] = true
                table.insert(queue, nb)
            end
        end
    end
    for _, goal in ipairs(goals) do
        if not visited[node_key(goal[1], goal[2])] then
            return false
        end
    end
    return true
end

return {
    is_fully_connected = is_fully_connected
}