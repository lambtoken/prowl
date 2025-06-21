local function load_all_from_dir(dir)
    local items = love.filesystem.getDirectoryItems(dir)
    local out = {}
    for _, item in ipairs(items) do
        if item:match("%.lua$") then
            local chunk = love.filesystem.load(dir .. "/" .. item)
            table.insert(out, chunk())
        end
    end
    return out
end

return load_all_from_dir