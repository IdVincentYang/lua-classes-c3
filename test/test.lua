
local Class = require("lualib/class")

--[[
  成员属性／函数：第一个非下划线字母小写
  类成员属性／函数：第一个非下划线字母大写

定义类:  class()
    - 类名：meta.name，string, optional


声明接口:   class() or class.interface()
    - 和声明类一样，区别是methods是字符串数组

添加类方法,属性
添加实例方法,属性
super
is <class, interface>: instanceof, isClass, isInterface
as <interface>

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

--  添加成员属性和方法
Biological.hp = 0

function Biological:ctor(args)
    print("create Biological instance:", self, args)
    if args then
        self.hp = args.hp
    end
end

function Biological:alive()
    return self.hp > 0
end

--  创建实例
--local biological = Biological()
--assert(biological)
--
----  调用成员函数和方法
--assert(biological.hp == 0)
--assert(biological:alive() == false)
--biological.hp = 3
--assert(biological:alive() == true)

--  branch class
local Animal = Class(Biological, "Animal")

Animal.speed = 0
Animal.eat = Class.ABSTRACT_FUNCTION

--function Animal:ctor(args)
--    print("create Animal instance:", self)
--    if args then
--        self.hp = args.hp
--    end
--end

assert(Animal.super == Biological)

--  leaf class
local PERSON_WALK_SPEED = 30
local Person = Class("Persion", Animal)

Person.language = "en"

function Person:ctor(args)
    print("create Person instance:", self, args)
    if args then
        self.hp = args.hp
    end
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

print("---------- Class Debug: ---------")
Class.debug()
--  接口

--  覆盖

--[[    features:
1.  lazy set fields:
1.  abstract:
2.  final:
3.  instance_cache: 通过接口实现
4.  lazy loader: 懒加载成员函数
 ]]