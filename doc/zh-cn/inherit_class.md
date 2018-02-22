类的继承
====
在面向对象编程时，从父类派生出子类是很自然的事情。
派生出的子类不需要任何编码就拥有了父类的所有属性和成员函数。
不同的子类通过覆盖父类的同名函数就可以实现类的多态性。
本库的实现是一种类的多继承方案，示例如下：

继承父类
----
类 O 为父类，定义了两个成员；类 A 为 O 的子类：
``` lua

local O = Class("O")
local A = Class("A", O)

O.inheritProperty = "Property Of O"

function O:testInherit()
    return "Method of O"
end
```
A 的实例拥有类 O 的所有成员，调用测试代码：
``` lua
local o1 = O()
local a1 = A()

print(o1.inheritProperty)
print(o1:testInherit())
print(a1.inheritProperty)
print(a1:testInherit())
```
输出为：
```
Property Of O
Method of O
Property Of O
Method of O
```

覆盖父类成员
----
类成员包含成员属性和成员函数两类。对于成员属性，子类和父类如果定义了同名属性，那么在类的实例中其实是同一个东西，但子类定义属性的初始值可能和父类定义同名属性的初始值不相同；考虑到初始化顺序、构造函数赋值以及多继承带来的复杂性，使用覆盖父类成员属性的代码在执行中很可能出现不是预料的结果；所以在具体的编码实践中不推荐覆盖父类成员属性。

以下示例演示覆盖父类成员函数，子类 A 定义和父类 O 定义同名的函数：
``` lua
function O:testOverride()
    return "Method of O"
end

function A:testOverride()
    return "Method of A"
end
```
子类中的函数会覆盖父类成员的函数，调用测试代码：
``` lua
local o2 = O()
local a2 = A()
print(o2:testOverride())
print(a2:testOverride())
```
输出为：
```
Method of O
Method of A
```

super 成员函数
----
1. super 函数是默认添加到类中的一个成员函数，在类的实现中可以通过 `self:super()` 调用。
2. super 函数返回的是一个父类的代理`table`对象，**不是真正的父类**。

派生类在覆盖父类函数时，很多情况下并不需要完全重新实现同名函数，只需要在父类函数的前后添加一些处理，然后调用父类函数：
``` lua
function O:testSuper()
    return "Method of O"
end

local B = Class("B", O)

function B:testSuper()
    --  在父类的结果前添加一个前缀
    local arr = {"Method of B"}
    arr[#arr + 1] = self:super():testSuper()
    return table.concat(arr, ":")
end
```
调用测试代码：
``` lua
print(B():testSuper())
```
输出为：
```
Method of B:Method of O
```

注意：

当多继承时，super 函数返回的结果是由[〝C3算法〞](https://en.wikipedia.org/wiki/C3_linearization)确定的MRO顺序决定的，可能是继承树上的父类，也可能是兄弟类。定义一个类 K1 继承 A 和 B 组成菱形结构：
``` lua
local K1 = Class("K1", A, B)

function K1:testSuper()
    local arr = {"Method of K1"}
    --  调用父类 B 的实现
    --  可以直接调用 B.testSuper(self)
    --  为了演示使用 super
    arr[#arr + 1] = self:super(A):testSuper()
    return table.concat(arr, ":")
end
```
调用测试代码：
``` lua
local k1 = K1()
print(k1:testSuper())
```
输出为：
```
Method of K1:Method of B:Method of O
```
注意到函数 `K1:testSuper` 的实现中父类的调用方式为 `self:super(A)` ，这是因为K1的MRO顺序为：K1,A,B,O。要调用B的实现，super要从A开始找；即对于类 K1， super(A) = B。
如果直接调用 `self:super()` 根据MRO顺序，super会找到父类A，然后调用 testSuper 函数时，会调用到基类 O 的同名函数：
``` lua
function K1:testSuper2()
    local arr = {"Method of K1"}
    arr[#arr + 1] = self:super():testSuper()
    return table.concat(arr, ":")
end

print(K1:testSuper2())
```
输出为：
```
Method of K1:Method of O
```
