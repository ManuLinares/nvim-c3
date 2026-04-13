# c3.nvim

<img src="https://c3-lang.org/logo.svg" align="right" height="120" />

Support for [C3](https://c3-lang.org) in Neovim.

- LSP auto-installation and setup ([tonis2/lsp](https://github.com/tonis2/lsp)).
- Tree-Sitter grammar and highlights ([tree-sitter-c3](https://github.com/c3lang/tree-sitter-c3)).
- Code formatting via `:C3Format` or `:Format` ([c3fmt](https://github.com/lmichaudel/c3fmt)).
- Diagnostic info via `:C3Info`.

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

## Configuration

Settings are optional. Default values:

```lua
require("c3").setup({
  lsp = {
    enable = true, -- Set to false to disable LSP
    cmd = "c3lsp",
  },
  formatter = {
    enable = true, -- Set to false to disable formatter
    cmd = "c3fmt",
    format_on_save = false,
  },
  highlighting = {
    enable_treesitter = true,
  }
})
```
