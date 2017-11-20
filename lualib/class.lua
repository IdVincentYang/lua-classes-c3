
local M = {}

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
            print(prefix, k..":", v)
            if vt == "table" then
                debug_table(v, level + 1)
            end
        end
    end
end

local dummy_func = function()
    print("----- dummy func called")
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

--  key: class, value: class members table
local members_map = {}

function M.debug()
    for class,_ in pairs(members_map) do
        local meta = getmetatable(class)
        print("Class ".. (meta.name or "<anonymous>")..":", class)
        debug_table(meta, 1)
    end
end

function M.Static(Class, name, val)
    rawset(Class, name, val)
end

local function make_constructor(class)
    local meta = getmetatable(class)
--    local class_name = meta.name or "<anonyous>"
--    print("!!+ make_constructor begin:", class_name, debug.traceback())
    local base, construct
    local ics, icn, extends = {}, 0, meta.extends
    for i = 2, #extends do
        base = extends[i]
        construct = getmetatable(base).construct or make_constructor(base)
        if construct ~= dummy_func then
            icn = icn + 1
            ics[icn] = construct
        end
    end

    local construct_super
    local base = class.super
    if base then
        construct_super = getmetatable(base).construct or make_constructor(base)
    else
        construct_super = M.OnInstantiate
    end

    local ctor = rawget(members_map[class], "ctor")
    if not ctor then
        if #ics == 0 then
            construct = construct_super
        else
            construct = function(instance, args)
                construct_super(instance, args)
                local arr, len = ics, #ics
                for i = len, 1, -1 do
                    arr[i](instance)
                end
            end
        end
    else
        if #ics == 0 then
            construct = function(instance, args)
                construct_super(instance, args)
                ctor(instance, args)
            end
        else
            construct = function(instance, args)
                construct_super(instance, args)
                local arr, len = ics, #ics
                for i = len, 1, -1 do
                    arr[i](instance)
                end
                ctor(instance, args)
            end
        end
    end
--    print("!!- make_constructor end:", class_name, construct)
    meta.construct = construct
    return construct
end

local function make_class(name, extends)
    local members = setmetatable({}, {
        __index = function(t, k)
            for _, base in ipairs(extends) do
                local m = members_map[base][k]
                if m ~= nil then
                    t[k] = m
--                    print("class ", name or "<anonymous>", "found member:", k, m, debug.traceback())
                    return m
                end
            end
        end
    })

    local class = {
        super = extends[1]
    }
    members_map[class] = members

    local instance_meta = {
        class = class,
        __index = members,
    }
    local class_meta = {
        name = name,
        extends = extends,
        instance = instance_meta,
        __newindex = function(t, k, v)
            --  有虚函数的类不能实例化
            if v == abstruct_func then
                getmetatable(t).abstract = true
            end
            members[k] = v
        end,
    }
    setmetatable(class, class_meta)
    class_meta.__call = function(_, args)
        if class_meta.abstract then
            --  检查 abstract 函数是否被覆盖掉
            for k, v in pairs(members) do
                if v == abstruct_func then
                    error("Can't instantiate abstract class!")
                end
            end
            --  no abstract
            class_meta.abstract = nil
        end
        local instance = setmetatable({}, instance_meta)
        local construct = class_meta.construct or make_constructor(class)
        construct(instance, args)
        return instance
    end

    return class
end

return setmetatable(M, {
    __call = function(_, ...)
        local args, extends = table.pack(...), {}
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
                if extends[arg] ~= nil then
                    --  重复了？
                    break
                end
                extends[arg] = true
                extends[#extends + 1] = arg
            until true
        end

        local class = make_class(name, extends)
        return class
    end
})