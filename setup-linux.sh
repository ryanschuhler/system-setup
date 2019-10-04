#!/bin/bash
# To install remotely run `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ryanschuhler/system-setup/master/setup-linux.sh)"`

# Install Apps
apt-get install curl git nodejs peco tig vim wget yank zsh
npm install -g gh gh-jira

# Configure
git clone https://github.com/ryanschuhler/system-setup.git ~

ln -s ~/.aliases ~/system-setup/.aliases

ln -s ~/.bash_profile ~/system-setup/.bash_profile
source ~/.bash_profile

ln -s ~/.bashrc ~/system-setup/.bashrc
source ~/.bashrc

ln -s ~/.gh.json ~/system-setup/.gh.json

ln -s ~/.gitconfig ~/system-setup/.gitconfig
source ~/.gitconfig

ln -s ~/.vim ~/system-setup/.vim

ln -s ~/.zshrc ~/system-setup/.zshrc
source ~/.zshrc
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
