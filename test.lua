#!/usr/bin/env lua
-- lua package stub
-- set package path for relative loading
local script = debug.getinfo(1, "S").source:sub(2)
local dir = script:match("(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
-- end of logic

print(require("object").BRACKETS["h"])
