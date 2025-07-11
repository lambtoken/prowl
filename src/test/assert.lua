local M = {}

M.enabled = true

function M.assert(condition, message)
    if not M.enabled then
        return
    end
    if not condition then
        local msg = message or "Assertion failed!"
        local trace = debug.traceback(msg, 2)
        error(trace, 0) -- full trace
    end
end

return M