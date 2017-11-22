
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