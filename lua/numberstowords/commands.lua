local M = {}
local RegexUtil = require("numbsub.regex_util")

local function parse_args(args)
	local pattern = nil
	local conversion_type = "c" -- Default to 'c' (cardinal)

	for _, arg in ipairs(args) do
		if arg:sub(1, 1) == "p" then
			pattern = arg:sub(2)
		elseif arg == "c" or arg == "o" then
			conversion_type = arg
		end
	end

	if not pattern then
		vim.api.nvim_err_writeln("Pattern not specified. Please prefix the pattern with 'p'.")
		return nil, nil
	end

	return pattern, conversion_type
end

-- Check and install num2words if not present
local function ensure_num2words_installed()
	local handle = io.popen("pip show num2words")
	local result = handle:read("*a")
	handle:close()

	if result == "" then
		vim.api.nvim_out_write("num2words not found. Installing...\n")
		os.execute("pip3 install num2words")
	end
end

local function number_to_words(number, conversion_type)
	local script_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h")
	local script_path = script_dir .. "/convert_numbers.py"

	-- Determine the command to execute based on number sign
	local python_cmd = string.format('python3 "%s" %d %s', script_path, number, conversion_type)

	-- Execute the command and read the result
	local handle = io.popen(python_cmd)
	local result = handle:read("*a")
	handle:close()

	-- Remove extra whitespace from the result
	return result:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
end

function M.convert_numbers_to_words(args)
	ensure_num2words_installed()
	local pattern, conversion_type = parse_args(args)
	if not pattern then
		return
	end

	_G.convert_numbers_to_words_helper = function()
		local current_value
		local current_value_str = vim.fn.matchstr(vim.fn.submatch(0), "-\\?\\d\\+")
		if current_value_str == "" then
			error("No numeric value found in the match")
		end
		current_value = tonumber(current_value_str)
		if current_value == nil then
			error("Failed to convert the matched value to a number")
		end

		return number_to_words(current_value)
	end
	-- Construct the Vim command for substitution
	local cmd = string.format("%%s/\\(%s\\)/\\=v:lua._G.convert_numbers_to_words_helper()/g", pattern)
	vim.cmd(cmd)
end

-- Function to convert a number to Roman numeral in Lua
local function number_to_roman(number)
	if type(number) ~= "number" or number < 1 or number > 3999 then
		return number
	end

	local roman_numerals = {
		{ 1000, "M" },
		{ 900, "CM" },
		{ 500, "D" },
		{ 400, "CD" },
		{ 100, "C" },
		{ 90, "XC" },
		{ 50, "L" },
		{ 40, "XL" },
		{ 10, "X" },
		{ 9, "IX" },
		{ 5, "V" },
		{ 4, "IV" },
		{ 1, "I" },
	}

	local result = ""
	for _, pair in ipairs(roman_numerals) do
		local value, roman = pair[1], pair[2]
		while number >= value do
			result = result .. roman
			number = number - value
		end
	end

	return result
end

function M.convert_numbers_to_roman(args)
	local pattern, _ = parse_args(args)
	if not pattern then
		return
	end

	_G.convert_numbers_to_roman_helper = function()
		local current_value
		local current_value_str = vim.fn.matchstr(vim.fn.submatch(0), "\\d\\+")
		if current_value_str == "" then
			error("No numeric value found in the match")
		end
		current_value = tonumber(current_value_str)
		if current_value == nil then
			error("Failed to convert the matched value to a number")
		end

		return number_to_roman(current_value)
	end
	-- Construct the Vim command for substitution
	local cmd = string.format("%%s/\\(%s\\)/\\=v:lua._G.convert_numbers_to_roman_helper()/g", pattern)
	vim.cmd(cmd)
end

return M
