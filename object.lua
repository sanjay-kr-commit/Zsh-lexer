#!/usr/bin/env lua

local object_table = {}

object_table.WHITESPACE = {
	[" "] = true,
	["\t"] = true,
}

object_table.OPERATORS = {
	[";"] = true,
	["|"] = true,
	["&"] = true,
	["<"] = true,
	[">"] = true,
}

object_table.BRACKETS = {
	["("] = true,
	[")"] = true,
	["["] = true,
	["]"] = true,
	["{"] = true,
	["}"] = true,
}

object_table.TOKEN_TYPE = {
	--
	WORD = 0,
	FUNCTION = 1,
	--
	COMMENT = 2,
	--
	COMMAND = 3,
	--
	NEW_LINE = 4,
	OPEN_BRACKET = 5,
	CLOSE_BRACKET = 6,
	SQURE_OPEN_BRACKET = 7,
	SQURE_CLOSE_BRACKET = 8,
	CURLY_OPEN_BRACKET = 9,
	CURLY_CLOSE_BRACKET = 10,
	--
	ARG = 11,
	AMPERSEN = 12,
	SEMICOLON = 13,
	PIPE = 14,
	FORWARD_REDIRECTION = 15,
	BACKWORD_REDIRECTION = 16,
}

object_table.INDEXED_TOKEN = {}

for name, value in pairs(object_table.TOKEN_TYPE) do
	object_table.INDEXED_TOKEN[value] = name
end

object_table.context_template = {
	token_pool = {},
	token_pool_size = 0,
	token = "",
	token_type = object_table.TOKEN_TYPE.WORD,
	token_started = false,
	single_quote_open = false,
	double_quote_open = false,
	comment_is_open = false,
	escape_next = false,
	last_char = "",
	file_name = "",
	line = -1,
	column = -1,
	max_line = 0,
	max_column = 0,
}

function object_table.context_template.copy(overrides)
	local context_copy = {}

	for key, value in pairs(object_table.context_template) do
		if type(value) == "table" then
			context_copy[key] = {}
			for k, v in pairs(value) do
				context_copy[key][k] = v
			end
		else
			context_copy[key] = value
		end
	end

	for key, value in pairs(overrides or {}) do
		context_copy[key] = value
	end
	return context_copy
end

return object_table
