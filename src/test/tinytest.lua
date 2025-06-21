local tinytest = {}

function tinytest.new()
  return {
    tests = {},
    add = function(self, name, fn)
      table.insert(self.tests, { name = name, fn = fn })
    end,
    run = function(self)
      local passed, failed = 0, 0
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
      print(("\n%d passed, %d failed"):format(passed, failed))
      if failed > 0 then os.exit(1) end
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
