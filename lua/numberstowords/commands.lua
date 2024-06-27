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
	local handle = io.popen(string.format("python3 %s %d %s", script_path, number, conversion_type))
	local result = handle:read("*a")
	handle:close()
	return result:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1") -- Remove extra whitespace
end

function M.convert_numbers_to_words(args)
	ensure_num2words_installed()
	local pattern, conversion_type = parse_args(args)
	if not pattern then
		return
	end

	-- Get lines
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Iterate through the lines in the specified range
	for i, line in ipairs(lines) do
		local matches = RegexUtil.get_vim_matches(pattern, line)

		-- Check if there are any matches in the current line
		if next(matches) ~= nil then
			for _, number in ipairs(matches) do
				local num = tonumber(number)
				if num then
					local words = number_to_words(num, conversion_type)
					local pattern_escaped = vim.pesc(number)
					local command = string.format("keepjumps keeppatterns :%ds/%s/%s", i, pattern_escaped, words)
					vim.cmd(command)
				end
			end
		end
	end
end

-- Function to convert a number to Roman numeral in Lua
local function number_to_roman(number)
	if type(number) ~= "number" then
		return ""
	end
	if number < 1 or number > 3999 then
		if number > 3999 then
			print("Number too big: ", number)
		end
		return ""
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

	-- Get lines
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Iterate through the lines in the specified range
	for i, line in ipairs(lines) do
		local matches = RegexUtil.get_vim_matches(pattern, line)

		-- Check if there are any matches in the current line
		if next(matches) ~= nil then
			for _, number in ipairs(matches) do
				local num = tonumber(number)
				if num then
					local roman_numeral = number_to_roman(num)
					if roman_numeral ~= "" then
						local pattern_escaped = vim.pesc(number)
						local command =
							string.format("keepjumps keeppatterns :%ds/%s/%s", i, pattern_escaped, roman_numeral)
						vim.cmd(command)
					end
				end
			end
		end
	end
end

-- Function to convert numbers to Roman numerals (dedicated command)
return M
