local subScene = {}

function subScene:new(name)

    local o = {
        name = name,
        x = 0,
        y = 0,
        w = 100,
        h = 100
    }

    setmetatable(o, self)
    self.__index = self
    return o
end

function subScene:onHover()
    self.x = self.x + 1
end

function subScene:draw()
    love.graphics.setColor(0, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

function subScene:mousemoved(x, y, dx, dy)
    if x >= self.x and y >= self.y and x <= self.x + self.w and y <= self.y + self.h then
        if self.onHover then self:onHover(x, y) end
        return true
    end
    return false
end

function subScene:enter() end
function subScene:exit() end

return subScene