#!/usr/bin/env lua

-- set package path for relative loading
local script = debug.getinfo(1, "S").source:sub(2)
local dir = script:match("(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
-- end of logic

local function_table = require("functions")
local lexer = require("lexer")

-- entry point
function_table.process(lexer.lexer, lexer.inspection_handler_std_out)
