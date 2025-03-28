local instance

local EventManager = {}
EventManager.__index = EventManager

function EventManager:new()
    local instance = {
        listeners = {}
    }
    setmetatable(instance, self)
    instance.__index = self
    return instance
end

-- function EventManager:newInstance()
--     instance = nil
--     instance = self:new()
--     return instance
-- end

function EventManager:getInstance()
    if not instance then
        instance = self:new()
    end
    
    return instance
end

function EventManager:on(event, callback)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end
    table.insert(self.listeners[event], callback)
end

function EventManager:emit(event, ...)
    if self.listeners[event] then
        for _, callback in ipairs(self.listeners[event]) do
            callback(...)
        end
    end
end

function EventManager:reset()
    self.listeners = {}
end

return EventManager

                                                                           
--                       ████████████                                        
--                     ██░░░░░░░░░░░░██                                      
--                   ██░░            ░░██                                    
--                 ██                  ░░██                                  
--                 ██████          ████░░██                                  
--                 ██    ██      ██    ░░██                                  
--                 ██      ░░██░░    ░░██                                    
--                 ██░░  ░░░░██░░░░████████                                  
--                   ██░░    ░░  ██        ██                                
--                     ██  ██  ██            ██                              
--                   ██░░██    ██░░░░          ██                            
--                     ██░░  ██  ██░░            ██                          
--                     ██░░██      ████░░░░  ░░░░░░██                        
--                       ██░░  ░░██    ██░░░░░░████                          
--                         ██▓▓██░░░░██  ██████                              
--                   ██████▓▓▓▓▓▓████░░    ██                                
--                   ████░░░░░░░░░░████░░░░░░██                              
--                   ██░░██░░░░░░██░░████████                                
--                   ██░░░░██▓▓██░░░░██                                      
--                   ██░░░░▓▓▓▓▓▓░░░░██                                      
--                   ██████████████████                                      