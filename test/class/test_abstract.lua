local Class = require("lualib/class")

local Reader = Class("Reader")
Reader.read = Class.ABSTRACT_FUNCTION

local Writer = Class("Writer")
Writer.write = Class.ABSTRACT_FUNCTION

--  有虚拟函数的类不能实例化
assert(pcall(Reader) == false)
assert(pcall(Writer) == false)

--  实现接口
local StringStream = Class("StringStream", Reader, Writer)

StringStream.src = ""
function StringStream:read(n)
    local ret = string.sub(self.src, 1, n)
    self.src = string.sub(self.src, n + 1)
    return ret
end
function StringStream:write(s)
    self.src = self.src .. s
end

local strStream = StringStream()
assert(strStream:read(1) == "")
strStream:write("abc")
assert(strStream:read(2) == "ab")
assert(strStream:read(2) == "c")
