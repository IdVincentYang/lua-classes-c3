local Class = require("lualib/class")

local test_cases = {
    "class/test_define",
    "class/test_inherit",
    "class/test_abstract",
}

for _, case in ipairs(test_cases) do
    print("-------------------- Testing:", case)
    require("test/"..case)
end

print("==================== All test done! ====================")
Class.debug()