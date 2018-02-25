local Class = require "c3class"

--  tostring(<class>) output class name or class address
local ClassWithName = Class("ClassWithName")
assert("class: ClassWithName" == tostring(ClassWithName))

local ClassWithoutName = Class()
assert(string.find(tostring(ClassWithoutName), "class: 0x") == 1)

--  tostring(<instance>) output 'instance of <class name or class address>: address'
local classWithName = ClassWithName()
assert(string.find(tostring(classWithName), "instance of ClassWithName:") == 1)

local AToString = Class("AToString")

function AToString:toString()
    return "A"
end
-- class BToString break overriding of function toString
local BToString = Class("BToString", AToString)

local CToString = Class("CToString", BToString)

function CToString:toString()
    return "C" .. self:super():toString()
end

local c = CToString()
assert("CA" == tostring(c))
