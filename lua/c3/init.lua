local M = {}

-- Pin version to match parser binary with highlight queries
M.TREE_SITTER_C3_VERSION = "v0.11.0"
M._is_compiling = false
M._compile_attempts = 0

M.config = {
	lsp = {
		enable = true,
		cmd = "c3lsp",
		version = "latest",
		compiler_path = nil,
		stdlib_path = nil,
	},
	formatter = {
		enable = true,
		cmd = "c3fmt",
		format_on_save = false,
		config_file = nil,
		version = "latest",
	},
	highlighting = {
		enable_treesitter = true,
	}
}

local PARSER_DIR = vim.fn.stdpath("data") .. "/c3-parser"
local PARSER_SO = PARSER_DIR .. "/c3.so"

local FORMATTER_DIR = vim.fn.stdpath("data") .. "/c3-fmt"
local FORMATTER_BIN = FORMATTER_DIR .. "/c3fmt" .. (vim.fn.has("win32") == 1 and ".exe" or "")

local LSP_DIR = vim.fn.stdpath("data") .. "/c3-lsp"
local LSP_BIN = LSP_DIR .. "/lsp" .. (vim.fn.has("win32") == 1 and ".exe" or "")

local function verify_query_compatibility(ts)
	return pcall(function()
		local get_query = ts.query.get or (vim.treesitter.query and vim.treesitter.query.get)
		if get_query then get_query("c3", "highlights") end
	end)
end

local function warn_outdated_rtp_parsers()
	local rtp_parsers = vim.api.nvim_get_runtime_file("parser/c3.so", true)
	if #rtp_parsers > 0 then
		local paths_str = table.concat(rtp_parsers, ", ")
		vim.schedule(function()
			vim.notify(
				"[nvim-c3] Warning: An outdated or incompatible C3 treesitter parser was found in your runtime path: " .. paths_str .. "\nThis will cause highlighting errors. Please remove or update this file.",
				vim.log.levels.WARN
			)
		end)
	end
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	-- Proactively register fallback parser at startup so all plugins (e.g. fzf-lua) use it immediately
	local ts_ok, ts = pcall(require, "vim.treesitter")
	if ts_ok then
		if vim.fn.filereadable(PARSER_SO) == 1 then
			pcall(function() ts.language.add("c3", { path = PARSER_SO }) end)
		end

		-- Warn immediately if there's an incompatible parser in rtp
		local has_parser = pcall(function() ts.language.inspect("c3") end)
		if has_parser then
			if not verify_query_compatibility(ts) then
				warn_outdated_rtp_parsers()
			end
		end
	end
end

local function get_download_version_path(version)
	if version == "latest" then
		return "latest/download"
	end
	return "download/" .. version
end

local function install_and_get_formatter(force)
	local cmd = M.config.formatter.cmd
	if vim.fn.executable(cmd) == 1 then return cmd end

	if not force and vim.fn.filereadable(FORMATTER_BIN) == 1 then return FORMATTER_BIN end

	if vim.fn.executable("curl") == 1 then
		vim.api.nvim_echo({{ "Downloading c3fmt (" .. M.config.formatter.version .. ") from GitHub...", "None" }}, false, {})
		vim.fn.mkdir(FORMATTER_DIR, "p")
		local os = vim.fn.has("mac") == 1 and "macos" or (vim.fn.has("win32") == 1 and "windows.exe" or "linux")

		local v_path = get_download_version_path(M.config.formatter.version)
		local url = string.format("https://github.com/lmichaudel/c3fmt/releases/%s/c3fmt-%s", v_path, os)

		vim.fn.system({ "curl", "-sL", url, "-o", FORMATTER_BIN })
		if vim.v.shell_error == 0 then
			if vim.fn.has("win32") == 0 then vim.fn.system({ "chmod", "+x", FORMATTER_BIN }) end
			vim.api.nvim_echo({{ "c3fmt installed successfully!", "None" }}, false, {})
			return FORMATTER_BIN
		end
	end
	return nil
end

function M.format()
	if not M.config.formatter.enable then return end
	local cmd_path = install_and_get_formatter()
	if not cmd_path then
		vim.notify("c3fmt not found and auto-install failed.", vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local input = table.concat(lines, "\n")

	local cmd_args = { cmd_path, "--stdin", "--stdout" }
	if M.config.formatter.config_file then
		local config_path = vim.fn.fnamemodify(tostring(M.config.formatter.config_file), ":p")
		table.insert(cmd_args, "--config=" .. config_path)
	end

	local output = vim.fn.system(cmd_args, input)

	if vim.v.shell_error == 0 and output ~= "" then
		local view = vim.fn.winsaveview()
		local new_lines = vim.split(output, "\n")
		-- Clean up trailing empty line from formatter stdout
		if new_lines[#new_lines] == "" then table.remove(new_lines) end

		vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
		if view then vim.fn.winrestview(view) end
	else
		vim.notify("c3fmt failed: " .. (output or "unknown error"), vim.log.levels.ERROR)
	end
end

local function install_and_get_lsp(force)
	local cmd = M.config.lsp.cmd
	if not force and vim.fn.executable(cmd) == 1 then return cmd end

	if not force and vim.fn.filereadable(LSP_BIN) == 1 then return LSP_BIN end

	local has_unzip = vim.fn.executable("unzip") == 1
	local has_tar = vim.fn.executable("tar") == 1
	local has_curl = vim.fn.executable("curl") == 1

	if has_curl and (has_unzip or has_tar) then
		vim.api.nvim_echo({{ "Downloading C3 LSP (" .. M.config.lsp.version .. ") from GitHub...", "None" }}, false, {})
		vim.fn.mkdir(LSP_DIR, "p")
		local os = vim.fn.has("mac") == 1 and "macos" or (vim.fn.has("win32") == 1 and "windows" or "linux")
		local uv = vim.uv or vim.loop
		local arch = uv.os_uname().machine
		arch = (arch:match("arm") or arch:match("aarch64")) and "aarch64" or "x86_64"

		local v_path = get_download_version_path(M.config.lsp.version)
		local url = string.format("https://github.com/tonis2/lsp/releases/%s/c3-lsp-%s-%s.zip", v_path, os, arch)
		local zip_path = LSP_DIR .. "/lsp.zip"

		vim.fn.system({ "curl", "-sL", url, "-o", zip_path })
		if vim.v.shell_error == 0 then
			if has_unzip then
				vim.fn.system({ "unzip", "-o", zip_path, "-d", LSP_DIR })
			else
				vim.fn.system({ "tar", "-xf", zip_path, "-C", LSP_DIR })
			end
			vim.fn.delete(zip_path)
			if vim.fn.has("win32") == 0 then vim.fn.system({ "chmod", "+x", LSP_BIN }) end
			vim.api.nvim_echo({{ "C3 LSP installed successfully!", "None" }}, false, {})
			return LSP_BIN
		end
	end
	return nil
end

function M.start_lsp(bufnr)
	if not M.config.lsp.enable then return end
	local cmd_path = install_and_get_lsp()
	if not cmd_path then return end

	local root_dir = vim.fs.dirname(vim.fs.find({'project.json', '.git'}, { upward = true })[1]) or vim.fn.getcwd()

	local cmd = { cmd_path }
	local compiler_path = M.config.lsp.compiler_path or (vim.fn.executable("c3c") == 1 and vim.fn.exepath("c3c") or nil)
	if compiler_path and compiler_path ~= "" then
		table.insert(cmd, "--compiler-path")
		table.insert(cmd, compiler_path)
	end

	local stdlib_path = M.config.lsp.stdlib_path
	if not stdlib_path and compiler_path then
		local build_env = vim.fn.system({ compiler_path, "compile", "-", "--build-env" })
		if vim.v.shell_error == 0 then
			for line in string.gmatch(build_env, "[^\r\n]+") do
				local path = string.match(line, "^Stdlib%s*:%s*(.-)%s*$")
				if path then
					stdlib_path = vim.fn.fnamemodify(path, ":p")
					break
				end
			end
		end
	end
	if stdlib_path and stdlib_path ~= "" then
		table.insert(cmd, "--stdlib-path")
		table.insert(cmd, stdlib_path)
	end

	pcall(function()
		vim.lsp.start({
			name = "c3lsp",
			cmd = cmd,
			root_dir = root_dir,
			on_attach = function(client, bnr)
				vim.bo[bnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
			end,
			workspace_folders = {
				{
					name = vim.fs.basename(root_dir) or "c3_project",
					uri = vim.uri_from_fname(root_dir),
				}
			}
		}, { bufnr = bufnr })
	end)
end

function M.compile_parser(force)
	local ts_ok, ts = pcall(require, "vim.treesitter")
	if not ts_ok then return false end

	if not force and vim.fn.filereadable(PARSER_SO) == 1 then
		pcall(function() ts.language.add("c3", { path = PARSER_SO }) end)
		return true
	end

	local compiler
	for _, cmd in ipairs({ "cc", "gcc", "clang", "zig cc" }) do
		local exec_name = string.match(cmd, "^([^ ]+)")
		if vim.fn.executable(exec_name) == 1 then
			compiler = cmd
			break
		end
	end

	if vim.fn.executable("git") == 1 and compiler then
		M._is_compiling = true
		M._compile_attempts = M._compile_attempts + 1
		vim.api.nvim_echo({{ "Compiling tree-sitter-c3 parser fallback...", "None" }}, false, {})

		vim.fn.delete(PARSER_DIR, "rf")

		local error_output = {}
		vim.fn.jobstart(string.format(
			"git clone --branch %s --depth 1 https://github.com/c3lang/tree-sitter-c3 '%s' && cd '%s' && %s -fPIC -shared src/parser.c src/scanner.c -I src -o c3.so",
			M.TREE_SITTER_C3_VERSION, PARSER_DIR, PARSER_DIR, compiler
		), {
			on_stderr = function(_, data)
				for _, line in ipairs(data) do
					if line ~= "" then table.insert(error_output, line) end
				end
			end,
			on_exit = function(_, exit_code)
				M._is_compiling = false
				vim.schedule(function()
					if exit_code == 0 then
						pcall(function() ts.language.add("c3", { path = PARSER_SO }) end)
						vim.api.nvim_echo({{ "c3 tree-sitter parser compiled successfully.", "None" }}, false, {})
					else
						local msg = "Failed to compile c3 tree-sitter parser: " .. table.concat(error_output, " "):sub(1, 100)
						vim.notify(msg, vim.log.levels.WARN)
					end
					vim.cmd("redraw")
				end)
			end
		})
		return true
	end

	return false
end

local function check_treesitter_parser()
	if not M.config.highlighting.enable_treesitter then
		return false
	end

	local ts_ok, ts = pcall(require, "vim.treesitter")
	if not ts_ok then return false end

	-- Prioritize our compiled fallback parser if it exists, to override outdated global binaries
	if vim.fn.filereadable(PARSER_SO) == 1 then
		pcall(function() ts.language.add("c3", { path = PARSER_SO }) end)
		
		-- Check if the compiled fallback works with our queries
		if verify_query_compatibility(ts) then
			return true
		end
	end

	local has_parser = pcall(function() ts.language.inspect("c3") end)
	if has_parser then
		-- Check if the inspected parser actually works with our queries
		if verify_query_compatibility(ts) then
			return true
		else
			warn_outdated_rtp_parsers()
		end
	end

	-- If we are already compiling or have already attempted compilation in this session, stop here to avoid infinite loops
	if M._is_compiling or M._compile_attempts > 0 then
		return has_parser
	end

	-- Try nvim-treesitter integration next
	local nvim_ts_ok, parsers = pcall(require, "nvim-treesitter.parsers")
	if nvim_ts_ok and type(parsers) == "table" and type(parsers.get_parser_configs) == "function" then
		local parser_configs = parsers.get_parser_configs()
		if not parser_configs.c3 then
			parser_configs.c3 = {
				install_info = {
					url = "https://github.com/c3lang/tree-sitter-c3",
					files = { "src/parser.c", "src/scanner.c" },
					revision = M.TREE_SITTER_C3_VERSION,
				},
				filetype = "c3",
			}
		end

		local install_mod_ok, install_mod = pcall(require, "nvim-treesitter.install")
		if install_mod_ok and install_mod.ensure_installed then
			install_mod.ensure_installed({ "c3" })
			return true
		end
	end

	-- If the parser is missing or outdated (failed query compilation), auto-compile our own fallback
	return M.compile_parser(true)
end

function M.setup_highlighting()
	-- Load basic syntax file first
	vim.cmd([[syntax enable]])
	vim.cmd([[runtime! syntax/c3.vim]])

	-- Then attempt to upgrade to tree-sitter
	local has_ts = check_treesitter_parser()
	if has_ts then
		pcall(function() vim.treesitter.start(0, "c3") end)
	end
end

function M.info()
	local status = { "C3 Plugin Status:", "" }
	
	local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ name = "c3lsp" })
	if #clients > 0 then
		table.insert(status, "LSP: Running (id: " .. clients[1].id .. ")")
	else
		table.insert(status, "LSP: Not running")
	end
	
	local has_ts = pcall(function() return vim.treesitter.get_parser(0, "c3") end)
	if has_ts then
		table.insert(status, "Tree-Sitter: Active")
	else
		table.insert(status, "Tree-Sitter: Inactive (using fallback syntax)")
	end

	local fmt = install_and_get_formatter()
	if fmt then
		table.insert(status, "Formatter: Ready (" .. fmt .. ")")
	else
		table.insert(status, "Formatter: Missing")
	end

	vim.api.nvim_echo({{ table.concat(status, "\n"), "None" }}, true, {})
end

function M.update(tool)
	if not tool or tool == "formatter" then
		install_and_get_formatter(true)
	end
	if not tool or tool == "lsp" then
		install_and_get_lsp(true)
	end
	if not tool or tool == "parser" then
		M.compile_parser(true)
	end
	if tool and tool ~= "formatter" and tool ~= "lsp" and tool ~= "parser" then
		vim.notify("Unknown tool for update: " .. tool, vim.log.levels.ERROR)
	end
end

return M
