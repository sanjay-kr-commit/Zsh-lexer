#!/usr/bin/env lua

-- set package path for relative loading
local script = debug.getinfo(1, "S").source:sub(2)
local dir = script:match("(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
-- end of logic

local object_table = require("object")
local M = {}

local function add_token(context)
  if context.token == "" then
    return
  end
  context.token_pool_size = context.token_pool_size + 1
  context.token_pool[context.token_pool_size] = {
	  type = context.token_type,
    value = context.token,
    line = context.line  ,
    column = context.column ,
	}
  context.token = ""
end

local function isBreak(context, char, lambda)
	if context.comment_is_open or context.double_quote_open or context.single_quote_open then
		return false
	end
	if object_table.BRACKETS[char] or object_table.OPERATORS[char] or char == "=" then
		-- todo
    add_token(context)
    context.token = char
    add_token(context)
		lambda()
		return true
	end
	if object_table.WHITESPACE[char] then
		-- todo
		lambda()
		return true
	end
	return false
end


function M.lexer(context, line)
  context.token_type = object_table.TOKEN_TYPE.WORD
  local prev_char = ""
  local column = 1
	for char in line:gmatch(".") do
    if prev_char == " " then
      context.column = column
    end
    column = column + 1
    if char == "'" and not context.double_quote_open and prev_char ~= '\\' and not context.comment_is_open then
      context.single_quote_open = not context.single_quote_open
      if context.single_quote_open then
        add_token(context)
      else
        context.token = context.token .. char
        add_token(context)
        goto end_of_loop
      end
    end
    if char == '"' and not context.single_quote_open and prev_char ~= '\\' and not context.comment_is_open then
      context.double_quote_open = not context.double_quote_open
      if context.double_quote_open then
        add_token(context)
      else
        context.token = context.token .. char
        add_token(context)
        goto end_of_loop
      end
    end
    if char == "#" and not context.comment_is_open and not context.single_quote_open and not context.double_quote_open then
      if not context.comment_is_open then
        add_token(context)
      end
      context.comment_is_open = true
      context.token = object_table.TOKEN_TYPE.COMMENT
    end
		if isBreak(context, char, function() end) then
			goto end_of_loop
		end
    context.token = context.token .. char
		::end_of_loop::
    prev_char = char
	end
  context.comment_is_open = false
	add_token(context)
  context.token = "NEW_LINE"
  context.token_type = object_table.TOKEN_TYPE.NEW_LINE
	add_token(context)
  if context.max_column < column then
    context.max_column = column
  end
end

function M.inspection_handler_std_out(context)

  local line_fmt = math.ceil(math.log(context.max_line,10))
  local column_fmt = math.ceil(math.log(context.max_column,10))
  local token_fmt = "%0" .. math.ceil(math.log(context.token_pool_size,10)) .. "d"
  local line_column_fmt = "%0" .. line_fmt .. "d:" .. "%0" .. column_fmt .. "d"
  local fmt = "> " .. token_fmt .. " | " .. line_column_fmt  .. " | %-20s | %q"

  local header_line_column_fmt = "%-" .. (line_fmt + column_fmt+1) .. "s"
  local header_token_fmt = "%-" .. math.ceil(math.log(context.token_pool_size,10)) .. "s"
  local header_fmt = "> " .. header_token_fmt .. " | " .. header_line_column_fmt  .. " | %-20s | %-s"

  print(string.format(header_fmt,
    "index" , "line:col" , "type" , "value"
  ))

	for index = 1, context.token_pool_size, 1 do
		print(
			string.format(
				fmt,
				index,
        context.token_pool[index].line ,
        context.token_pool[index].column,
				object_table.INDEXED_TOKEN[context.token_pool[index].type],
				context.token_pool[index].value
			)
		)
	end
end

return M
