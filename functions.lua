#!/usr/bin/env lua

-- set package path for relative loading
local script = debug.getinfo(1, "S").source:sub(2)
local dir = script:match("(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
-- end of logic

local object = require("object")

local function is_piped()
	local p = io.popen("test -t 0 && echo yes || echo no")
	if not p then
		return false
	end
	local result = p:read("*l") == "no"
	p:close()
	return result
end

local function args_process(context, lexer)
	local file = io.open(context.file_name, "r")
	if file == nil then
		io.stderr:write("failed to open file : " .. context.file_name .. "\n")
		return false
	end
	local line_count = 0
	for line in file:lines() do
		line_count = line_count + 1
		context.line = line_count
		lexer(context, line)
	end
	context.max_line = line_count
	file:close()
	return true
end

local function_table = {}

function function_table.process(lexer, process_context)
	if is_piped() then
		local context = object.context_template.copy({
			file_name = "<stdin>",
		})
		local line_count = 0
		for line in io.stdin:lines() do
			line_count = line_count + 1
			context.line = line_count
			lexer(context, line)
		end
		context.max_line = line_count
		process_context(context)
	elseif #arg ~= 0 then
		for _, value in ipairs(arg) do
			local context = object.context_template.copy({
				file_name = value,
			})
			if args_process(context, lexer) then
				process_context(context)
			end
		end
	else
		io.stderr:write("Pass a file name or pipe a file content\n")
	end
end

return function_table
