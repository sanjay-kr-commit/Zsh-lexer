#!/usr/bin/env lua

-- set package path for relative loading
local script = debug.getinfo(1, "S").source:sub(2)
local dir = script:match("(.*/)") or "./"
package.path = dir .. "?.lua;" .. package.path
-- end of logic

local object_table = require("object")
local lexer_table = {}

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

local function is_break(context, prev_char, char, lambda)
	if context.comment_is_open or context.double_quote_open or context.single_quote_open then
		return false
	end
  if prev_char ~= '\\' and object_table.BRACKETS[char] ~= nil then
    add_token(context)
    context.token_type = object_table.BRACKETS[char]
    context.token = char
    add_token(context)
    context.token_type = object_table.TOKEN_TYPE.WORD
		lambda()
		return true
  end
  if prev_char ~= '\\' and object_table.OPERATORS[char] ~= nil then
    add_token(context)
    context.token_type = object_table.OPERATORS[char]
    context.token = char
    add_token(context)
    context.token_type = object_table.TOKEN_TYPE.WORD
		lambda()
		return true
  end
	if prev_char ~= '\\' and object_table.WHITESPACE[char] then
    add_token(context)
		lambda()
		return true
	end
	return false
end

function lexer_table.lexer(context, line)
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
    end
    if char == '"' and not context.single_quote_open and prev_char ~= '\\' and not context.comment_is_open then
      context.double_quote_open = not context.double_quote_open
    end
    if char == "#" and not context.comment_is_open and not context.single_quote_open and not context.double_quote_open then
      if not context.comment_is_open then
        add_token(context)
      end
      context.comment_is_open = true
      context.token_type = object_table.TOKEN_TYPE.COMMENT
    end
		if is_break(context, prev_char , char, function()
      context.column = column
    end) then
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

return lexer_table
