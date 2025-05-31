local fontPaths = require 'src.render.fontPaths'

local fonts = {}

local function getFont(name, size)
    assert(name and size, "Missing font name or size")

    fonts[name] = fonts[name] or {}

    if not fonts[name][size] then
        local path = fontPaths[name]
        assert(path, ("Font path not found for name: %s"):format(name))
        local font = love.graphics.newFont(path, size)
        fonts[name][size] = font
    end

    return fonts[name][size]
end

return getFont
