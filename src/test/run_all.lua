local all_tests = require("src/utility/loadAllFromDir")("src/test/tests")

return function()
    for _, test in ipairs(all_tests) do
        if type(test) == "function" then
            test()
        elseif type(test) == "table" and test.run then
            test:run()
        else
            print("Skipping non-test module:", test)
        end
    end
end