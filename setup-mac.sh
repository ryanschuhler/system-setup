#!/bin/bash

# Install homebrew
xcode-select --install
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Apps
brew install curl git nodejs peco tig yank vim zsh
npm install -g gh gh-jira

# Download
cd ~ && git clone https://github.com/ryanschuhler/system-setup.git

# Configure
ln -s ~/.aliases ~/system-setup/.aliases
ln -s ~/.bash_profile ~/system-setup/.bash_profile
ln -s ~/.bashrc ~/system-setup/.bashrc
ln -s ~/.gh.json ~/system-setup/.gh.json
ln -s ~/.gitconfig ~/system-setup/.gitconfig
ln -s ~/.vim ~/system-setup/.vim
ln -s ~/.zshrc ~/system-setup/.zshrc
