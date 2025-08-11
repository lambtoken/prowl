local all_tests = require("src/utility/loadAllFromDir")("src/test/tests")

return function()
    local total_passed, total_failed = 0, 0
    local test_files_run = 0
    
    for _, test in ipairs(all_tests) do
        if type(test) == "function" then
            test()
            test_files_run = test_files_run + 1
        elseif type(test) == "table" and test.run then
            local passed, failed = test:run()
            if passed and failed then
                total_passed = total_passed + passed
                total_failed = total_failed + failed
            end
            test_files_run = test_files_run + 1
            print()
        else
            print("Skipping non-test module:", test)
        end
    end
    
    -- total summary
    local total_tests = total_passed + total_failed
    if total_tests > 0 then
        local pass_ratio = (total_passed / total_tests) * 100
        print(string.format("=== TOTAL RESULTS ==="))
        print(string.format("Test files run: %d", test_files_run))
        print(string.format("Total tests: %d passed, %d failed", total_passed, total_failed))
        print(string.format("Pass ratio: %.1f%% (%d/%d)", pass_ratio, total_passed, total_tests))
        
        if total_failed > 0 then 
            os.exit(1) 
        end
    end
end