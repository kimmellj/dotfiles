#!/bin/bash
cd "$(dirname "$0")"
git pull

# Switch Shell to ZSH
chsh -s $(which zsh)

# Install Oh-My-ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install PowerLevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Execute Brewfile and ConfigureMacOS only on MacOS
if [[ "$(uname)" == "Darwin" ]]; then
    ./platform/macos/brewfile
    ./platforms/macos/configure
fi

# Copy Configs
rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "iterm/" -av . ~

./.brew

git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
