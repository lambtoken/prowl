local fontPaths = require 'src.render.fontPaths'

local fonts = {}

function getFont(name, size)
    assert(name and size, "Missing some arguments!")
    if not fonts[name] then
        fonts[name] = {}
        fonts[name][size] = love.graphics.newFont(fontPaths[name], size)
    end

    if not fonts[name][size] then
        fonts[name][size] = love.graphics.newFont(fontPaths[name], size)
    end

    return fonts[name][size]
end

return getFont