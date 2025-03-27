local InputManager = {}

function InputManager:init()
    local obj = {}
    setmetatable(obj, { __index = InputManager })
    obj.listeners = {}
    return obj
end

function InputManager:registerListener(listener, key)
    self.listeners[key] = listener
end

function InputManager:unregisterListener(key)
    self.listeners[key] = nil
end

function InputManager:keypressed(key, scancode, isrepeat)
    for _, listener in pairs(self.listeners) do
        if listener.keypressed then
            listener.keypressed(key, scancode, isrepeat)
        end
    end
end

local keyboardInputManager = InputManager:init()

return keyboardInputManager