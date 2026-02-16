#!/bin/bash
set -e

echo "=== LazyVim Setup for macOS ==="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew found, updating..."
    brew update
fi

# Install core dependencies
echo "Installing core dependencies..."
brew install neovim lua luarocks ripgrep fd git curl wget

# Optional: Install Node.js if not present (needed for some LSPs)
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    brew install node
fi

# Completely remove existing Neovim config
echo "Removing existing Neovim config..."
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Clone LazyVim starter
echo "Installing LazyVim..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Manually bootstrap lazy.nvim to prevent errors
echo "Bootstrapping lazy.nvim..."
mkdir -p ~/.local/share/nvim/lazy
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \
  ~/.local/share/nvim/lazy/lazy.nvim

# Optional: Install Java development tools
read -p "Install Java development tools (jdtls)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Java tools..."
    brew install jdtls

    # Create Java plugin config
    mkdir -p ~/.config/nvim/lua/plugins
    cat > ~/.config/nvim/lua/plugins/java.lua << 'EOF'
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "java" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {},
      },
    },
  },
}
EOF
    echo "Java tools configured"
fi

# Optional: Install lazygit
read -p "Install lazygit for git integration? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew install lazygit
    echo "lazygit installed"
fi

# Optional: Install better terminal emulator
read -p "Install Kitty terminal emulator? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew install --cask kitty
    echo "Kitty installed - launch with 'kitty' command"
fi

# Optional: Install Neovide GUI
read -p "Install Neovide (GUI app for Neovim)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew install neovide
    echo "Neovide installed - launch with 'neovide' command"
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Run 'nvim' to start Neovim. LazyVim will install plugins on first launch."
echo "This may take a minute or two."
echo ""
echo "Essential keybindings:"
echo "  <Space>     - Leader key (shows all commands with which-key)"
echo "  <Space>ff   - Find files"
echo "  <Space>sg   - Search in files"
echo "  <Space>e    - Toggle file explorer"
echo ""
echo "After first launch, run ':checkhealth' to verify everything is working."
echo ""
