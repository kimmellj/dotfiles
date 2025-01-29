#!/bin/bash
cd "$(dirname "$0")"
git pull

# Switch Shell to ZSH
chsh -s $(which zsh)

# Install Oh-My-ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Copy Configs
rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" --exclude "README.md" --exclude "iterm/" -av . ~
