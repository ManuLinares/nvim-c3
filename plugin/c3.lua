if vim.g.loaded_c3 == 1 then
	return
end
vim.g.loaded_c3 = 1

local c3 = require("c3")

vim.api.nvim_create_user_command("C3Info", function()
	c3.info()
end, { desc = "Show C3 plugin status" })

vim.api.nvim_create_user_command("C3Update", function(cmd_args)
	c3.update(cmd_args.args ~= "" and cmd_args.args or nil)
end, {
	nargs = "?",
	complete = function()
		return { "lsp", "formatter", "parser" }
	end,
	desc = "Update C3 LSP, formatter, or tree-sitter parser",
})

