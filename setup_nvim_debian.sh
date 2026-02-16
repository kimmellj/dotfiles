#!/bin/bash
set -e

echo "=== LazyVim Setup for Debian ==="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
   echo "Please don't run as root. Run as your regular user (sudo will be called when needed)."
   exit 1
fi

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install core dependencies
echo "Installing core dependencies..."
sudo apt install -y \
    git \
    curl \
    wget \
    build-essential \
    gcc \
    make \
    unzip \
    ripgrep \
    fd-find \
    nodejs \
    npm \
    lua5.1 \
    luarocks

# Install Neovim (latest stable via AppImage for better compatibility)
echo "Installing Neovim..."
if ! command -v nvim &> /dev/null; then
    cd /tmp
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.appimage
    chmod u+x nvim-linux-arm64.appimage
    ./    sudo mv nvim-linux-arm64.appimage /usr/local/bin/nvim

    echo "Neovim installed to /usr/local/bin/nvim"
else
    echo "Neovim already installed"
fi

# Create fd symlink (Debian installs it as fdfind)
if [ -f /usr/bin/fdfind ] && [ ! -f /usr/local/bin/fd ]; then
    sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
    echo "Created fd symlink"
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
    sudo apt install -y default-jdk

    # Install jdtls manually (Debian might not have it packaged)
    mkdir -p ~/.local/share/jdtls
    cd ~/.local/share/jdtls
    JDTLS_VERSION=$(curl -s https://download.eclipse.org/jdtls/snapshots/ | grep -oP 'jdt-language-server-\d+\.\d+\.\d+-\d+\.tar\.gz' | sort -V | tail -1)
    wget "https://download.eclipse.org/jdtls/snapshots/$JDTLS_VERSION"
    tar -xzf "$JDTLS_VERSION"
    rm "$JDTLS_VERSION"

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
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
    echo "lazygit installed"
fi

# Optional: Install better terminal emulator (if not headless)
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    read -p "Install Kitty terminal emulator? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt install -y kitty
        echo "Kitty installed - launch with 'kitty' command"
    fi

    # Optional: Install Neovide GUI
    read -p "Install Neovide (GUI app for Neovim)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Neovide needs to be built from source or installed via cargo on Debian
        if ! command -v cargo &> /dev/null; then
            echo "Installing Rust (needed for Neovide)..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        fi
        echo "Installing Neovide dependencies..."
        sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
        echo "Building Neovide (this may take a few minutes)..."
        cargo install --git https://github.com/neovide/neovide
        echo "Neovide installed - launch with 'neovide' command"
    fi
else
    echo "No display detected - skipping GUI applications"
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
