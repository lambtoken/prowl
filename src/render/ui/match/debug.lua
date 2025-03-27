local debugConfig = require "src.render.ui.match.debugConfig"

local debug = {}

debug.load = function(match)
    --debug.match = match
    --debug.data = {}
end

debug.update = function(dt)
    debug.data.fps = love.timer.getFPS()
end

debug.draw = function(tileX , tileY)
    love.graphics.print(tostring(debug.data.fps), debugConfig.leftMargin + 0, debugConfig.bottomMargin + 0, 0, debugConfig.fontSize)
    love.graphics.print('asdsdds', 0, 0, 0, debugConfig.fontSize)

end

return debug