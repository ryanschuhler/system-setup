#!/bin/bash
# To install remotely run `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ryanschuhler/system-setup/master/setup-mac.sh)"`
# Other Apps to download: VS Code, Trailer, Spotify

# Install homebrew
xcode-select --install
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Apps
brew install curl fzf gh git nodejs python3 terminal-notifier tig vim wget zsh

sudo ln -sfn /usr/local/opt/openjdk@8/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-8.jdk

wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg -O ~/Downloads/googlechrome.dmg
open ~/Downloads/googlechrome.dmg

wget https://download.docker.com/mac/stable/Docker.dmg -O ~/Downloads/Docker.dmg
open ~/Downloads/Docker.dmg

# Configure

ssh-keygen -t rsa -b 4096 -C "ryan.schuhler@liferay.com"
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/id_rsa
pbcopy < ~/.ssh/id_rsa.pub
open https://github.com/settings/keys

git clone git@github.com:ryanschuhler/system-setup.git ~/repos/system-setup
sleep 10s

ln -s ~/repos/system-setup/.aliases ~/.aliases

ln -s ~/repos/system-setup/.bash_profile ~/.bash_profile
source ~/.bash_profile

ln -s ~/repos/system-setup/.bashrc ~/.bashrc
source ~/.bashrc

ln -s ~/repos/system-setup/.gitconfig ~/.gitconfig

ln -s ~/repos/system-setup/.gitconfig ~/.tigrc

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -s ~/repos/system-setup/.vimrc ~/.vimrc
source ~/.vimrc
vim +PluginInstall

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sleep 10s
ln -s ~/repos/system-setup/.zshrc ~/.zshrc
source ~/.zshrc
