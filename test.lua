#!/usr/bin/env lua
-- lua package stub
-- set package path for relative loading
local script = debug.getinfo(1, "S").source:sub(2)
local dir = script:match("(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
-- end of logic

local object_table = require("object")
local test_table = {}

function test_table.inspection_handler_std_out(context)
	local line_fmt = math.ceil(math.log(context.max_line, 10))
	local column_fmt = math.ceil(math.log(context.max_column, 10))
	local token_fmt = "%0" .. math.ceil(math.log(context.token_pool_size, 10)) .. "d"
	local line_column_fmt = "%0" .. line_fmt .. "d:" .. "%0" .. column_fmt .. "d"
	local fmt = "> " .. token_fmt .. " | " .. line_column_fmt .. " | %-20s | %q"
	local header_line_column_fmt = "%-" .. (line_fmt + column_fmt + 1) .. "s"
	local header_token_fmt = "%-" .. math.ceil(math.log(context.token_pool_size, 10)) .. "s"
	local header_fmt = "> " .. header_token_fmt .. " | " .. header_line_column_fmt .. " | %-20s | %-s"
	print(string.format(header_fmt, "index", "line:col", "type", "value"))
	for index = 1, context.token_pool_size, 1 do
		print(
			string.format(
				fmt,
				index,
				context.token_pool[index].line,
				context.token_pool[index].column,
				object_table.INDEXED_TOKEN[context.token_pool[index].type],
				context.token_pool[index].value
			)
		)
	end
end

return test_table
