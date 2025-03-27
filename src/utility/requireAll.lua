local function requireAll(directory)
    local files = love.filesystem.getDirectoryItems(directory)

    for _, file in ipairs(files) do
        local filepath = directory .. "/" .. file
        
        if file:sub(-4) == ".lua" then
            local moduleName = filepath:sub(1, -5):gsub("/", ".")
            require(moduleName)
        end
    end
end

return requireAll