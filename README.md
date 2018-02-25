
Lua Classes C3
======
Lua c3class 模块是一个支持多继承的面向对象编程功能库，多继承算法使用 [C3 superclass linearization algorithm](https://en.wikipedia.org/wiki/C3_linearization)。

Lua c3class module is an OOP library which supports multi-inheritance using the [C3 superclass linearization algorithm](https://en.wikipedia.org/wiki/C3_linearization) .

|[中文文档](./doc/zh-cn/contents.md)|English Doc|

特性[Feature]
----
|||
|:--|:--|
|遵循 Lua 习惯写法|Follow Habit of Lua Writing|
|支持多继承|Support Multi-inheritance|
|支持 super 方法|Support Super Method|
|有很多便利开发的工具函数|Many Utility Functions Facilitates Developing|

示例[Quick Usage]
----
``` lua
--  MyClass.lua
local Class = require "c3class"

--  define a class
local MyClass = Class("MyClassName", {
    aIntProperty = 0,
    aStringProperty = "abc",
    aTableProperty = {1, 2, 3}
})
--  define cumtom construct function
function MyClass:ctor()
    local array = {}
    for i,v in ipairs(self.aTableProperty) do
        array[i] = v
    end
    self.aTableProperty = array
end
--  define class methods
function MyClass:foo()
    print("foo")
end

function MyClass:bar()
    print("bar")
end
--  define class static members
Class.Static(MyClass, "AStaticIntProperty", 3)
Class.Static(MyClass, "AStaticStringProperty", "STATIC")
Class.Static(MyClass, "StaticFunction", function(...)
    --  do some thing
end)

--  export module
return MyClass
```

安装[Install]
----

1. 使用 luarocks 安装：`luarocks install lua-c3class`
2. 直接拷贝模块文件 `c3class.lua` 到项目工程中

<br>

1. Install via luarocks: `luarocks install lua-c3class`
2. Copy module file `c3class.lua` to Project Folder

版本计划[Version Plan]
----
* [TODO]1.0: 添加 Lua 5.1 支持
* [TODO]0.9: 添加 API 文档和英文文档
* [TODO]0.8: 支持不同的运行环境配置：development 和 production，development 环境做更多的检查并输出友好的错误信息
* [DONE]0.7: 第一个发布版本
    1. [功能] 实现类的多继承
    2. [功能] 支持类自定义 `ctor` 构造函数
    2. [功能] 支持 `super` 成员函数
    3. [功能] 添加类和实例的默认 `tostring` 实现

<br>

* [TODO]1.0: Support Lua 5.1
* [TODO]0.9: Add API Documents and English Documents
* [TODO]0.8: Support Running Environment Configure：development 和 production, Under development Environment do more check and output friendly error message
* [DONE]0.7: The First Release Version
    1. [new] Implement Multi-inheritance
    2. [new] Support Custom Constructor: `ctor`
    2. [new] Support `super` member function
    3. [new] Add Default `tostring` implements for Classes and Instances