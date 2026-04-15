#!/bin/bash
set -e

# This script is intended to run inside a clean Arch Linux container
# to verify the installation and functionality of nvim-c3.

echo "--- Installing Dependencies ---"
pacman -Syu --noconfirm
pacman -S --noconfirm neovim git curl unzip tar base-devel

echo "--- Setting up LazyVim starter ---"
git clone https://github.com/LazyVim/starter ~/.config/nvim

echo "--- Adding nvim-c3 (from /workspace) ---"
mkdir -p ~/.config/nvim/lua/plugins
cat << 'EOF' > ~/.config/nvim/lua/plugins/c3.lua
return {
  { 
    dir = "/workspace", 
    name = "nvim-c3", 
    config = true,
  }
}
EOF

echo "--- Initializing Neovim ---"
nvim --headless "+Lazy! sync" +qa > /dev/null 2>&1

echo "--- Testing Dependency Updates ---"
nvim --headless "+lua require('c3').update()" +qa

echo "--- Verifying Binaries ---"
C3FMT=~/.local/share/nvim/c3-fmt/c3fmt
C3LSP=~/.local/share/nvim/c3-lsp/lsp

if [ -f "$C3FMT" ] && [ -f "$C3LSP" ]; then
    echo "SUCCESS: Binaries downloaded successfully!"
    echo "c3fmt version:"
    "$C3FMT" --version
    echo "C3 LSP version:"
    "$C3LSP" --version
else
    echo "FAILURE: Binaries and/or LSP missing."
    exit 1
fi

echo "--- Plugin Info ---"
nvim --headless "+lua require('c3').info()" +qa
