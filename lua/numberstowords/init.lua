local M = {}
local myCommand = "NumbersToWords"
local commands = require("numberstowords.commands")

-- Define the custom command in Neovim
function M.setup()
	vim.api.nvim_create_user_command("NumbersToWords", function(args)
		commands.convert_numbers_to_words(args.fargs)
	end, { nargs = "+" })

	vim.api.nvim_create_user_command("NumbersToRoman", function(args)
		commands.convert_numbers_to_roman(args.fargs)
	end, { nargs = "+" })
end

return M
