local Class = require("lualib/class")

----------------------------------------------------------------------------
--  Base Class

--  root class
local Biological = Class()
assert(Biological)

--  添加静态成员和方法
Class.Static(Biological, "Counter", 0)
Class.Static(
    Biological,
    "GetCount",
    function()
        return Biological.Counter
    end
)

--  添加成员属性和方法
Biological.hp = 0

function Biological:ctor(args)
    Biological.Counter = Biological.Counter + 1
end

function Biological:alive()
    return self.hp > 0
end

--  创建实例
local biological = Biological()
assert(Biological.GetCount() == 1)

----  调用成员函数和方法
assert(biological.hp == 0)
assert(biological:alive() == false)
biological.hp = 3
assert(biological:alive() == true)

----------------------------------------------------------------------------
--  Derived Classes

local Animal = Class(Biological, "Animal")

Animal.speed = 0
Animal.eat = Class.ABSTRACT_FUNCTION

local PERSON_WALK_SPEED = 30
local Person = Class("Persion", Animal)

Class.Static(Person, "Counter", 0)
Class.Static(
    Person,
    "GetCount",
    function()
        return Person.Counter
    end
)

Person.language = "en"

function Person:ctor(args)
    Person.Counter = Person.Counter + 1
end

function Person:eat(food)
    if food then
        self.hp = self.hp + 1
    end
end

function Person:IsStand()
    return self.speed == 0
end
function Person:walk()
    self.speed = PERSON_WALK_SPEED
end

--  创建实例
local person1 = Person()
assert(person1:alive() == false)
person1:eat("some thing")
assert(person1:alive() == true)

local person2 = Person(person1)
assert(person2:alive() == true)

assert(Biological.GetCount() == 3)

----------------------------------------------------------------------------
--  Recommended Class Defination

local MyClass =
    Class(
    "MyClassName",
    {
        aIntProperty = 0,
        aStringProperty = "abc",
        aTableProperty = {1, 2, 3}
    }
)

function MyClass:ctor()
    local array = {}
    for i, v in ipairs(self.aTableProperty) do
        array[i] = v
    end
    self.aTableProperty = array
end

function MyClass:foo(s)
    return "foo" .. s
end

function MyClass:bar(s)
    return "bar" .. s
end

Class.Static(MyClass, "AStaticIntProperty", 3)
Class.Static(MyClass, "AStaticStringProperty", "STATIC")
Class.Static(
    MyClass,
    "StaticFunction",
    function(...)
        --  do some thing
        return "StaticFunction"
    end
)

assert(MyClass.AStaticIntProperty == 3)
assert(MyClass.AStaticStringProperty == "STATIC")
assert(MyClass.StaticFunction() == "StaticFunction")

local myClass1 = MyClass()
local myClass2 = MyClass()

assert(myClass1.aIntProperty == 0)
assert(myClass1.aStringProperty == "abc")

myClass1.aIntProperty = 1
myClass2.aIntProperty = 2
assert(myClass1.aIntProperty == 1 and myClass2.aIntProperty == 2)

myClass2.aStringProperty = "def"
assert(myClass1.aStringProperty .. myClass2.aStringProperty == "abcdef")
assert(myClass1:foo(myClass2:bar("abc")) == "foobarabc")
