local tinytest = {}

function tinytest.new(test_set_name)
  return {
    name = test_set_name or "unnamed test set",
    tests = {},
    add = function(self, name, fn)
      table.insert(self.tests, { name = name, fn = fn })
    end,
    run = function(self)
      local passed, failed = 0, 0
      print("Running tests for " .. self.name)
      for _, t in ipairs(self.tests) do
        local ok, err = xpcall(t.fn, debug.traceback)
        if ok then
          print("✔ " .. t.name)
          passed = passed + 1
        else
          print("✘ " .. t.name .. "\n  ↳ " .. err)
          failed = failed + 1
        end
      end
      print(("%d passed, %d failed"):format(passed, failed))
      return passed, failed
    end
  }
end

function tinytest.eq(a, b)
  if a ~= b then
    error("Expected " .. tostring(b) .. ", got " .. tostring(a), 2)
  end
end

function tinytest.ok(value)
  if not value then
    error("Expected truthy value, got " .. tostring(value), 2)
  end
end

function tinytest.fail(value)
  if value then
    error("Expected falsy value, got " .. tostring(value), 2)
  end
end

function tinytest.raises(fn)
  local ok = pcall(fn)
  if ok then
    error("Expected error, but function ran without error", 2)
  end
end

function tinytest.ne(a, b)
  if a == b then
    error("Expected different values, but both were " .. tostring(a), 2)
  end
end

return tinytest
