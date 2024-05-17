#!/bin/bash
# To install remotely run `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ryanschuhler/system-setup/master/setup-linux.sh)"`

# Install Apps
apt-get install ca-certificates curl git gnupg lsb-release nodejs tig vim wget zsh

## Add Docker GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

## Add Docker apt repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

## Update sources and install Docker Engine
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose docker-compose-plugin

## Enable the Docker engine to start at boot
systemctl enable docker

## Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

ln -s ~/repos/system-setup/.tigrc ~/.tigrc

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