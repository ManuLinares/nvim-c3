local c3 = require("c3")
local bufnr = vim.api.nvim_get_current_buf()

if c3.config.formatter.format_on_save then
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		callback = function()
			c3.format()
		end,
	})
end

vim.api.nvim_buf_create_user_command(bufnr, "C3Format", function()
	c3.format()
end, { desc = "Format current C3 buffer" })

vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
	c3.format()
end, { desc = "Format current C3 buffer" })

vim.api.nvim_buf_create_user_command(bufnr, "C3Info", function()
	c3.info()
end, { desc = "Show C3 plugin status" })

vim.api.nvim_buf_create_user_command(bufnr, "C3Update", function(cmd_args)
	c3.update(cmd_args.args ~= "" and cmd_args.args or nil)
end, {
	nargs = "?",
	complete = function()
		return { "lsp", "formatter", "parser" }
	end,
	desc = "Update C3 LSP, formatter, or tree-sitter parser",
})

c3.start_lsp(bufnr)
c3.setup_highlighting()
