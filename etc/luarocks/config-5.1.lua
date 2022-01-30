-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" };
   { name = "system", root = "/var/lapis/luajit/" };
}
lua_interpreter = "luajit";
variables = {
   LUA_DIR = "/var/lapis/luajit";
   LUA_BINDIR = "/var/lapis/luajit/bin";
}
