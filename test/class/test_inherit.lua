local Class = require "c3class"

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

----------------------------------------------------------------------------
--  super test

local TestSuperA =
    Class(
    "TestSuperA",
    {
        propertyA = "A"
    }
)

function TestSuperA:append(str)
    return str .. self.propertyA
end

local testSuperA = TestSuperA()
assert(testSuperA:append("STRING_") == "STRING_A")

local TestSuperB, super =
    Class(
    "TestSuperB",
    TestSuperA,
    {
        propertyB = "B"
    }
)

function TestSuperB:append(str)
    return super(self):append(str) .. self.propertyB
end

assert(TestSuperB():append("STRING_") == "STRING_AB")

local TestSuperC, super =
    Class(
    "TestSuperC",
    TestSuperA,
    {
        propertyC = "C"
    }
)

function TestSuperC:append(str)
    return super(self):append(str) .. self.propertyC
end

assert(TestSuperC():append("STRING_") == "STRING_AC")

local TestSuperD, super =
    Class(
    "TestSuperD",
    TestSuperB,
    TestSuperC,
    {
        propertyD = "D"
    }
)

function TestSuperD:append(str)
    return super(self):append(str) .. self.propertyD
end

function TestSuperD:appendAlter(str)
    return super(self, TestSuperB):append(str) .. self.propertyD
end

local testSuperD = TestSuperD()
--  different of python, python should return "STRING_ACBD"
assert(testSuperD:append("STRING_") == "STRING_ABD")

assert(testSuperD:appendAlter("STRING_") == "STRING_ACD")
