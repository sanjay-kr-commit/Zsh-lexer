#!/usr/bin/env lua

-- set package path for relative loading
local script = debug.getinfo(1, "S").source:sub(2)
local dir = script:match("(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
-- end of logic

local interface_table = require("interface")
local lexer_table = require("lexer")
local test_table = require("test")

-- entry point
interface_table.intercept(lexer_table.lexer, test_table.inspection_handler_std_out)
