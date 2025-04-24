local class = require "libs.middleclass"

local test = class("Test")

function test:run()
    return self:callback()
end

return test