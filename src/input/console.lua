local GameState = require("src.state.GameState"):getInstance()
local console = {
    visible = false,
    height = 200,
    targetY = -200,
    currentY = -200,
    text = "",
    pointer = 0,
    history = {},
    commands = {}
}

local font = love.graphics.newFont(14)

function console:toggle()
    self.visible = not self.visible
    self.targetY = self.visible and 0 or -self.height
end

function console:update(dt)
    self.currentY = self.currentY + (self.targetY - self.currentY) * math.min(10 * dt, 1)
end

function console:draw()
    if not self.visible then
        return
    end

    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, self.currentY, love.graphics.getWidth(), self.height)
    love.graphics.setColor(1, 1, 1, 1)

    local lineHeight = 16
    local maxLines = math.floor((self.height - 30) / lineHeight)
    local start = math.max(1, #self.history - maxLines + 1)

    for i = start, #self.history do
        local line = self.history[i]
        love.graphics.print(line, 10, self.currentY + 10 + (i - start) * lineHeight)
    end

    love.graphics.print("> " .. self.text, 10, self.currentY + self.height - 24)
end


function console:textinput(t)
    self.text = self.text .. t
end

function console:_keypressed(key)
    if key == "return" then
        table.insert(self.history, "> " .. self.text)
        self:execute(self.text)
        self.text = ""
    elseif key == "backspace" then
        self.text = self.text:sub(1, #self.text - 1)
    elseif key == "tab" then
        local prefix = self.text:match("^%S*") or ""
        local matches = {}
        for name in pairs(self.commands) do
            if name:sub(1, #prefix) == prefix then
                table.insert(matches, name)
            end
        end
        table.sort(matches)
        if #matches == 1 then
            self.text = matches[1] .. " "
        elseif #matches > 1 then
            table.insert(self.history, "Matches: " .. table.concat(matches, ", "))
        end
    -- elseif key == "up" then
    --     -- i ll fix this later
    --     self.text = self.history[#self.history - self.pointer]
    --     self.pointer = self.pointer + 1
    end
end


function console:execute(cmd)
    if cmd == "" then
        return
    end

    local args = {}
    for word in cmd:gmatch("%S+") do
        table.insert(args, word)
    end
    local command = table.remove(args, 1)
    local fn = self.commands[command]
    if fn then
        local result = fn(unpack(args))
        if result then table.insert(self.history, tostring(result)) end
    else
        table.insert(self.history, "Unknown command: " .. command)
    end

    self.pointer = 0
end

function console:register(command, fn)
    self.commands[command] = fn
end

-- Setup
function console:load_commands()
    console:register("clear", function() self.history = {} end)
    console:register("hello", function() return "Hi there!" end)
    console:register("speed", function(sp)
        local num = tonumber(sp)
        if type(num) ~= "number" then
            table.insert(self.history, "Game speed must be a number!")
            return nil
        end
        GameState.settings.speed = sp 
        return "Gamespeed set to " .. sp 

    end)
    console:register("add", function(a, b)
        local numa = tonumber(a)
        local numb = tonumber(b)
        if type(numa) ~= "number" or type(numb) ~= "number" then
            table.insert(self.history, "Both arguments must be numbers!")
            return nil
        end
        
        return tonumber(a) + tonumber(b)
    end)
    console:register("killx", function()
        if not GameState.match and not GameState.run then
            table.insert(self.history, "No match in progress.")
            return nil
        end
        for _, entity in  ipairs(GameState.match.ecs:getEntities()) do
            GameState.match.stateSystem:changeState(entity, "dead")
        end
    end)
    console:register("win", function()
        if not GameState.match and not GameState.run then
            table.insert(self.history, "No match in progress.")
            return nil
        end
        GameState.match.winnerId = 1
        GameState.match.states:set_state("result")
    end)
end

function love.textinput(t)
    if console.visible then
        console:textinput(t)
    end
end

function console:keypressed(key)
    if key == "f1" then
        console:toggle()
    elseif console.visible then
        console:_keypressed(key)
    end
end

return console