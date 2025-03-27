local mouse = {}

mouse.update = function(dt)
    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.leftDown = love.mouse.isDown(1)
end

return mouse