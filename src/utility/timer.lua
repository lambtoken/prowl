local middleclass = require "libs.middleclass"

local Timer = middleclass("Timer")

function Timer:initialize(time, callback, oneshot)
    self.oneshot = oneshot or true
    self.time = time
    self.timer = 0
    self.callback = callback
    self.running = true
end

function Timer:update(dt)

    if not self.running then
        return
    end

    if self.timer <= self.time then
        self.timer = self.timer + dt
    else
        self.callback()
        if not self.oneshot then
            self.timer = 0
            return
        end

        self.running = false

    end
end

function Timer:resume()
    self.running = true
end

function Timer:reset()
    self.running = true
    self.time = 0
end

function Timer:stop()
    self.running = false
end

function Timer:pause()
    self.running = not self.running
end

return Timer