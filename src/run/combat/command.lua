local Command = {}

function Command:new()
    local command = {}
    setmetatable(command, self)
    self.__index = self
    command.completed = false
    command.type = nil
    return command
end

function Command:execute()
end

function Command:update(dt)
end

function Command:undo()
end

function Command:isCompleted()
    return self.completed
end

return Command