package = "lua-c3class"
version = "0.7-1"

source = {
    url = "git://github.com/IdVincentYang/lua-classes-c3.git"
}

description = {
    summary = "An implementation of the [C3 superclass linearization algorithm](https://en.wikipedia.org/wiki/C3_linearization) with Lua.",
    detailed = [[]],
    homepage = "https://github.com/IdVincentYang/lua-classes-c3",
    license = "MIT"
}

dependencies = {
    "lua >= 5.2, < 5.4"
}

build = {
    type = "builtin",
    modules = {
        ["c3class"] = "c3class.lua"
    },
    copy_directories = {
        "doc",
        "test",
        "README.md",
    }
}
