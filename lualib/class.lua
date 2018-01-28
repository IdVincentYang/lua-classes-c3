local M = {}

local function class_get_name(class)
    return getmetatable(class).name or "<anonymous>"
end

local function throw(...)
    local strs = table.pack(...)
    for i = 1, #strs do
        strs[i] = tostring(strs[i])
    end
    error(table.concat(strs, "\t"))
end

local function debug_table(t, level)
    level = level or 0
    local prefix = {}
    for i = 1, level do
        prefix[i] = "\t"
    end
    prefix = table.concat(prefix, "")
    for k, v in pairs(t) do
        local kt, vt = type(k), type(v)
        if kt == "table" then
            print(prefix, "\tkey:", k)
            debug_table(k, level + 1)
            print(prefix, "\tvalue:", v)
            if vt == "table" then
                debug_table(v, level + 2)
            end
        else
            print(prefix, k .. ":", v)
            if vt == "table" then
                debug_table(v, level + 1)
            end
        end
    end
end

local dummy_func = function()
    print("----- dummy func called at", debug.traceback())
end
local abstruct_func = function(self)
end

M.debug_table = debug_table
M.ABSTRACT_FUNCTION = abstruct_func
M.OnInstantiate = function(instance, args)
    if args ~= nil and type(args) == "table" then
        for k, v in pairs(args) do
            local type_v = type(v)
            if type_v == "boolean" or type_v == "number" or type_v == "string" then
                instance[k] = v
            end
        end
    end
end

--  key: class name, value: class; anonymous class in array part.
local class_map = {}

local function register_class(class, name)
    if name ~= nil then
        class_map[name] = class
    else
        class_map[#class_map + 1] = class
    end
end

function M.debug()
    print("--------- debug class: ---------")
    for _, class in pairs(class_map) do
        local meta = getmetatable(class)
        print("Class " .. (meta.name or "<anonymous>") .. ":", class)
        debug_table(meta, 1)
    end
end

function M.IsClass(c)
    local is_class = false
    repeat
        if type(c) ~= "table" then
            break
        end
        local meta = getmetatable(c)
        if not meta then
            break
        end
        if type(meta.mro) ~= "table" then
            break
        end
        if meta.name then
            is_class = class_map[meta.name] and true or false
            break
        end
        for i = 1, #class_map do
            if c == class_map[i] then
                is_class = true
                break
            end
        end
    until true
    return is_class
end

function M.Static(Class, name, val)
    rawset(Class, name, val)
end

local function instance_index_lazy(instance, member)
    local instance_meta = getmetatable(instance)
    local class_meta = getmetatable(instance_meta.class)
    --  把 mro 中的类的真正 members 取出来放到一个数组中
    local fmro = {class_meta.members}
    local mro = class_meta.mro
    for i = 2, #mro do
        fmro[i] = getmetatable(mro[i]).members
    end
    instance_meta.__index = function(t, k)
        local mro = fmro
        local m, v
        for i = 1, #mro do
            m = mro[i]
            v = m[k]
            if v ~= nil then
                t[k] = v
                return v
            end
        end
    end

    return instance_meta.__index(instance, member)
end

local function class_set_member(class, k, v)
    getmetatable(class).members[k] = v
end

local function class_is_abstract(class)
    local mro = getmetatable(class).mro
    --  从基类开始合并所有的成员函数
    local funcs = {}
    for i = #mro, 1, -1 do
        for k, v in pairs(getmetatable(mro[i]).members) do
            if type(v) == "function" then
                funcs[k] = v
            end
        end
    end
    local af = abstruct_func
    --  判断最终的所有成员函数中是否有 abstruct 函数
    for _, f in pairs(funcs) do
        if f == af then
            return true
        end
    end
    return false
end

local function class_make_construct(class)
    local mro = getmetatable(class).mro
    local ctors = {M.OnInstantiate}
    local ctor
    for i = #mro, 1, -1 do
        ctor = getmetatable(mro[i]).members.ctor
        if ctor then
            ctors[#ctors + 1] = ctor
        end
    end
    return function(instance, args)
        local cs = ctors
        for i = 1, #cs do
            cs[i](instance, args)
        end
    end
end

local function class_call_lazy(class, args)
    local class_meta = getmetatable(class)
    --  构造 instance metatable
    local instance_meta = {
        class = class,
        __index = instance_index_lazy
    }
    --  生成类实例创建函数
    class_meta.__call = function(_, args)
        local clazz = class
        local meta = class_meta
        local abstract = meta.abstract
        if abstract == nil then
            abstract = class_is_abstract(clazz)
            meta.abstract = abstract
        end
        if abstract == true then
            return throw("can't instantiate abstract class", class_get_name(clazz))
        end

        local instance = setmetatable({}, instance_meta)
        local construct = meta.construct
        if not construct then
            construct = class_make_construct(clazz)
            meta.construct = construct
        end
        construct(instance, args)
        return instance
    end
    return class_meta.__call(class, args)
end

--  操作 mros 中的数组中的元素时，使用增加数组偏移量的方式来避免移动数组中的元素
--  mros's element style: { idx: <start index>, num: <class num>, arr: <origin array> }
local function merge_mro(out, mros)
    local n = #mros
    if n == 0 then
        return out
    end
    local in_tail = false
    local mro, h, m, i, j
    i = 1
    while i < n do
        repeat
            --  取出第i个tail中的第一个元素
            mro = mros[i]
            if mro.num == 0 then
                --  此 mro 已空了，取下一个的
                break
            end
            --  取出第 i 个 mro 中的头
            h = mro.arr[mro.idx]
            --  判断其它 mro 中是否有 h 在 tail 中
            j = 1
            while j <= n do
                if i == j then
                    if j == n then
                        break
                    else
                        j = j + 1
                    end
                end
                m = mros[j]
                j = j + 1
                local arr = m.arr
                local v = m.idx + m.num
                for u = m.idx + 1, v do
                    if arr[u] == h then
                        in_tail = true
                        break
                    end
                end

                if in_tail then
                    break
                end
            end
            --  如果  在其它 mro 的 tail 中，取下一个 mro 的 h
            if in_tail then
                in_tail = false
                break
            end
            --  输出 h
            out[#out + 1] = h
            --  删除 mros 中所有 h
            for k = 1, n do
                mro = mros[k]
                if mro.num > 0 and mro.arr[mro.idx] == h then
                    mro.idx = mro.idx + 1
                    mro.num = mro.num - 1
                end
            end
            i = 0
        until true
        i = i + 1
    end
    --  如果遍历完了 mros 但是还是有 h 在别的 mro 的 tail 中，说明无法 merge
    if in_tail then
        return nil
    else
        return out
    end
end

--  https://en.wikipedia.org/wiki/C3_linearization
local function make_class_c3(name, extends, members)
    --  先声明类
    local class = {}
    --  构建mro序列
    local tail_mros = {}
    local base_num = #extends
    for i = 1, base_num do
        local base_mro = getmetatable(extends[i]).mro
        tail_mros[i] = {
            idx = 1,
            num = #base_mro,
            arr = base_mro
        }
        tail_mros[base_num + i] = {
            idx = i,
            num = 1,
            arr = extends
        }
    end
    local mro = merge_mro({class}, tail_mros)
    if mro == nil then
        local base_names = {}
        for i = 1, #extends do
            base_names[i] = class_get_name(extends[i])
        end
        return throw("Cannot create a consistent method resolution order (MRO) for bases", table.unpack(base_names))
    end

    return setmetatable(
        class,
        {
            members = members,
            mro = mro,
            name = name,
            __newindex = class_set_member,
            __call = class_call_lazy
        }
    )
end

return setmetatable(
    M,
    {
        __call = function(_, ...)
            local args, extends, members = table.pack(...), {}, {}
            local arg, arg_type, name
            for i = 1, args.n do
                arg = args[i]
                repeat
                    if arg == nil then
                        break
                    end
                    arg_type = type(arg)
                    if arg_type == "string" then
                        if name then
                        --  已经有名称了？
                        end
                        assert(#arg > 0)
                        --  检查此名称是否已被使用
                        name = arg
                        break
                    end
                    if arg_type ~= "table" then
                        break
                    end
                    if not M.IsClass(arg) then
                        --  此 arg 不是类，认为是定义类成员的 table，把 members 合并到 members 变量
                        for k, v in pairs(arg) do
                            members[k] = v
                        end
                        break
                    end
                    if extends[arg] ~= nil then
                        --  重复了？
                        break
                    end
                    extends[arg] = true
                    extends[#extends + 1] = arg
                until true
            end
            if name ~= nil and class_map[name] then
                return throw("there is class registered with this name", name, class_map[name])
            end
            local class = make_class_c3(name, extends, members)
            register_class(class, name)
            return class
        end
    }
)
