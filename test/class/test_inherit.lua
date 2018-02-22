local Class = require("lualib/class")

----------------------------------------------------------------------------
--  C3 Linearization Wiki Example

local O = Class("O")
local A = Class("A", O)
local B = Class("B", O)
local C = Class("C", O)
local D = Class("D", O)
local E = Class("E", O)
local K1 = Class("K1", A, B, C)
local K2 = Class("K2", D, B, E)
local K3 = Class("K3", D, A)
local Z = Class("Z", K1, K2, K3)

local names = {}
local mro = getmetatable(Z).mro
for _, class in ipairs(mro) do
    names[#names + 1] = getmetatable(class).name
end

assert("Z,K1,K2,K3,D,A,B,C,E,O" == table.concat(names, ","))

----------------------------------------------------------------------------
--  Inheritance Example Test

--  inheritance example
O.inheritProperty = "Property Of O"

function O:testInherit()
    return "Method of O"
end

local o1 = O()
local a1 = A()

assert("Property Of O" == o1.inheritProperty)
assert("Method of O" == o1:testInherit())
assert("Property Of O" == a1.inheritProperty)
assert("Method of O" == a1:testInherit())

--  override example
function O:testOverride()
    return "Method of O"
end

function A:testOverride()
    return "Method of A"
end

local o2 = O()
local a2 = A()

assert("Method of O" == o2:testOverride())
assert("Method of A" == a2:testOverride())

--  super example
function O:testSuper()
    return "Method of O"
end

function B:testSuper()
    local arr = {"Method of B"}
    arr[#arr + 1] = self:super():testSuper()
    return table.concat(arr, ":")
end

assert("Method of B:Method of O" == B():testSuper())

--  Class O, A, B, K1 Made Diamond Inheritance
function K1:testSuper()
    local arr = {"Method of K1"}
    arr[#arr + 1] = self:super(A):testSuper()
    return table.concat(arr, ":")
end

function K1:testSuper2()
    local arr = {"Method of K1"}
    arr[#arr + 1] = self:super():testSuper()
    return table.concat(arr, ":")
end

local k1 = K1()

assert("Method of K1:Method of B:Method of O" == k1:testSuper())
assert("Method of K1:Method of O" == k1:testSuper2())
