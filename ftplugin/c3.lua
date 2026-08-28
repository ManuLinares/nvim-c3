local c3 = require("c3")
local bufnr = vim.api.nvim_get_current_buf()

local format_on_save = (c3.config.lsp and c3.config.lsp.format_on_save)
	or (c3.config.formatter and c3.config.formatter.format_on_save)

if format_on_save then
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		callback = function()
			c3.format({ bufnr = bufnr })
		end,
	})
end

vim.api.nvim_buf_create_user_command(bufnr, "C3Format", function(args)
	local range = nil
	if args.range == 2 then
		range = {
			["start"] = { args.line1, 0 },
			["end"] = { args.line2, -1 },
		}
	end
	c3.format({ bufnr = bufnr, range = range })
end, { range = true, desc = "Format current C3 buffer or range via LSP" })

vim.api.nvim_buf_create_user_command(bufnr, "Format", function(args)
	local range = nil
	if args.range == 2 then
		range = {
			["start"] = { args.line1, 0 },
			["end"] = { args.line2, -1 },
		}
	end
	c3.format({ bufnr = bufnr, range = range })
end, { range = true, desc = "Format current C3 buffer or range via LSP" })

vim.api.nvim_buf_create_user_command(bufnr, "C3Info", function()
	c3.info()
end, { desc = "Show C3 plugin status" })

vim.api.nvim_buf_create_user_command(bufnr, "C3Update", function(cmd_args)
	c3.update(cmd_args.args ~= "" and cmd_args.args or nil)
end, {
	nargs = "?",
	complete = function()
		return { "lsp", "parser" }
	end,
	desc = "Update C3 LSP or tree-sitter parser",
})

c3.start_lsp(bufnr)
c3.setup_highlighting()
