
local Class = require("lualib/class")

--[[
  成员属性／函数：第一个非下划线字母小写
  类成员属性／函数：第一个非下划线字母大写

添加类方法,属性
添加实例方法,属性

 ]]

--[[    实现继承
--  1.  子类继承父类的属性和方法，可以添加自己的方法
--  2.  子类实例可以通过 self 调用父类的静态成员和方法
 ]]

----------------------------------------------------------------------------
--  定义类：

--  root class
local Biological = Class()
assert(Biological)

--  添加静态成员和方法
Class.Static(Biological, "Counter", 0)
Class.Static(Biological, "GetCount", function()
    return Biological.Counter
end)

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
--
----  调用成员函数和方法
assert(biological.hp == 0)
assert(biological:alive() == false)
biological.hp = 3
assert(biological:alive() == true)

--  branch class
local Animal = Class(Biological, "Animal")

Animal.speed = 0
Animal.eat = Class.ABSTRACT_FUNCTION

--  leaf class
local PERSON_WALK_SPEED = 30
local Person = Class("Persion", Animal)

Class.Static(Person, "Counter", 0)
Class.Static(Person, "GetCount", function()
    return Person.Counter
end)

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

assert(Person.GetCount() == 2)
assert(Biological.GetCount() == 3)
print("---------- Test inherit done. ---------")
