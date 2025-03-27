local function createEnum(tbl)
    return setmetatable({}, {
        __index = tbl,
        __newindex = function() error("Attempt to modify an enum") end,
        __metatable = false
    })
end

return createEnum