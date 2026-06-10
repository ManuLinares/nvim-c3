# c3.nvim

<img src="logo.svg" align="right" height="120" />

Support for [C3](https://c3-lang.org) in Neovim.

- LSP auto-installation and setup ([tonis2/lsp](https://github.com/tonis2/lsp)).
- Tree-Sitter grammar and highlights ([tree-sitter-c3](https://github.com/c3lang/tree-sitter-c3)).
- Code formatting via `:C3Format` or `:Format` ([c3fmt](https://github.com/lmichaudel/c3fmt)).
- Diagnostic info via `:C3Info`.
- `:C3Update [tool]`: Updates dependencies (`lsp`, `formatter`, or both).

Just install the plugin and open a `.c3` file. Everything is hopefully managed automatically.

## Dependencies

- `c3c` (C3 compiler) must be in your `PATH`.
- `git` and a C compiler (`gcc`, `clang`, etc.) to build Tree-Sitter.
- `curl` and `tar` (or `unzip`) to download LSP and formatter.

## Installation

### lazy.nvim
```lua
{
  "ManuLinares/nvim-c3",
  build = function() require("c3").update() end, -- (Optional) Auto-update binaries
  config = true,
}
```

### vim-plug
```vim
Plug 'ManuLinares/nvim-c3'
```

### packer.nvim
```lua
use {
  'ManuLinares/nvim-c3',
  config = function()
    require("c3").setup()
  end
}
```

### Vanilla Neovim (Native Packages)
If you do not use a package manager, install the plugin using Neovim's built-in package system by cloning it into your startup packpath:

```bash
git clone https://github.com/ManuLinares/nvim-c3 ~/.local/share/nvim/site/pack/plugins/start/nvim-c3
```

Then, initialize the plugin by adding these lines to your `init.lua`:

```lua
require("c3").setup()

-- Enable inline diagnostic error messages (disabled by default in stock Neovim)
vim.diagnostic.config({ virtual_text = true })
```



<details>
<summary><b>Quick Install Guide (Arch Linux)</b></summary>

```bash
# 1. Install dependencies
sudo pacman -S neovim git curl unzip tar base-devel c3c

# 2. Setup LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim

# 3. Add this plugin
cat << 'EOF' > ~/.config/nvim/lua/plugins/c3.lua
return {
  { "ManuLinares/nvim-c3", config = true }
}
EOF
```
</details>

<details>
<summary><b>Quick Install Guide (Ubuntu / Debian)</b></summary>

```bash
# 1. Install dependencies
sudo apt update && sudo apt install -y neovim git curl unzip tar build-essential

# 2. Install c3c (Download manually)
mkdir -p ~/.local
curl -sL https://github.com/c3lang/c3c/releases/latest/download/c3-linux.tar.gz | tar -xz -C ~/.local
echo 'export PATH="$HOME/.local/c3:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 3. Setup LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim

# 4. Add this plugin
cat << 'EOF' > ~/.config/nvim/lua/plugins/c3.lua
return {
  { "ManuLinares/nvim-c3", config = true }
}
EOF
```
</details>

### Vim (without Neovim)

If you use plain Vim (not Neovim), copy the plugin directory into your Vim runtime path:

```bash
cp -r . ~/.vim
```

You'll get filetype detection and syntax highlighting for `.c3`, `.c3i`, and `.c3t` files out of the box.

> **Note:** LSP, Tree-Sitter highlighting, formatting, and all `:C3*` commands require Neovim and are not available in plain Vim.

## Configuration

Settings are optional. Default values:

```lua
require("c3").setup({
  lsp = {
    enable = true, -- Set to false to disable LSP
    cmd = "c3lsp",
    version = "latest", -- (2)
    compiler_path = nil, -- Custom path to c3c binary (3)
    stdlib_path = nil, -- Custom path to C3 standard library (3)
  },
  formatter = {
    enable = true, -- Set to false to disable formatter
    cmd = "c3fmt",
    format_on_save = false,
    config_file = nil, -- Path to .c3fmt file (1)
    version = "latest", -- (2)
  },
  highlighting = {
    enable_treesitter = true,
  }
})
```

- *(1): Path to a `.c3fmt` configuration file. If a relative path is used, it is resolved from Neovim's current working directory (see `:pwd`). See [c3fmt configuration](https://github.com/lmichaudel/c3fmt#configuration) for more details.*
- *(2): Minimum version or tag name from GitHub (e.g., `"v0.1.4"`). Defaults to `"latest"`.*
- *(3): Paths are automatically resolved by locating `c3c` on your system path and querying the standard library path via `c3c compile - --build-env`. Provide absolute paths here only to explicitly override the automatic detection.*
