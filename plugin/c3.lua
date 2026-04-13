if vim.g.loaded_c3 == 1 then
	return
end
vim.g.loaded_c3 = 1

local c3 = require("c3")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "c3",
	callback = function(args)
		if c3.config.formatter.format_on_save then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				callback = function()
					c3.format()
				end,
			})
		end

		vim.api.nvim_buf_create_user_command(args.buf, "C3Format", function()
			c3.format()
		end, {})

		vim.api.nvim_buf_create_user_command(args.buf, "Format", function()
			c3.format()
		end, {})
		
		vim.api.nvim_buf_create_user_command(args.buf, "C3Info", function()
			c3.info()
		end, {})

		c3.start_lsp(args.buf)

		c3.setup_highlighting()
	end,
})
