#!/bin/bash
# To install remotely run `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ryanschuhler/system-setup/master/setup-mac.sh)"`

# Install homebrew
xcode-select --install
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Apps
brew install curl git nodejs peco tig vim wget yank zsh
npm install -g gh gh-jira

brew cask install java

wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg -O ~/Downloads/googlechrome.dmg
open ~/Downloads/googlechrome.dmg

wget https://download.docker.com/mac/stable/Docker.dmg -O ~/Downloads/Docker.dmg
open ~/Downloads/Docker.dmg

wget https://downloads.slack-edge.com/mac_releases/Slack-4.0.3-macOS.dmg -O ~/Downloads/Slack-4.0.3-macOS.dmg
open ~/Downloads/Slack-4.0.3-macOS.dmg

wget https://www.jetbrains.com/idea/download/download-thanks.html?platform=machttps://download-cf.jetbrains.com/idea/ideaIU-2019.2.3.dmg -O ~/Downloads/ideaIU-2019.2.3.dmg
open ~/Downloads/ideaIU-2019.2.3.dmg

wget https://www.iterm2.com/nightly/latest -O ~/Downloads/iTerm.zip
unzip ~/Downloads/iTerm.zip -d ~/Downloads/
sudo cp -r ~/Downloads/iTerm.app /Applications/

wget https://github.com/ptsochantaris/trailer/releases/download/1.6.17/trailer1617.zip -O ~/Downloads/trailer.zip
unzip ~/Downloads/trailer.zip -d ~/Downloads/
sudo cp -r /Volumes/Trailer.app /Applications/

wget https://download.scdn.co/SpotifyInstaller.zip -O ~/Downloads/SpotifyInstaller.zip
unzip ~/Downloads/SpotifyInstaller.zip -d ~/Downloads/
open ~/Downloads/Install\ Spotify.app

open -a "Google Chrome" https://apps.apple.com/us/app/mail-for-gmail/id1216244845?mt=12

open -a "Google Chrome" https://apps.apple.com/us/app/magnet/id441258766?mt=12

open -a "Google Chrome" https://apps.apple.com/us/app/mini-calendar/id1088779979?mt=12

# Configure

ssh-keygen -t rsa -b 4096 -C "ryan.schuhler@liferay.com"
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/id_rsa
pbcopy < ~/.ssh/id_rsa.pub
open https://github.com/settings/keys

git clone git@github.com:ryanschuhler/system-setup.git ~/repos/

ln -s ~/repos/system-setup/.aliases ~/.aliases

ln -s ~/repos/system-setup/.bash_profile ~/.bash_profile
source ~/.bash_profile

ln -s ~/repos/system-setup/.bashrc ~/.bashrc
source ~/.bashrc

ln -s ~/repos/system-setup/.gh.json ~/.gh.json

ln -s ~/repos/system-setup/.gitconfig ~/.gitconfig
source ~/.gitconfig

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ln -s ~/repos/system-setup/.vimrc ~/.vimrc
source ~/.vimrc
vim +PluginInstall +qall

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
ln -s ~/repos/system-setup/.zshrc ~/.zshrc
source ~/.zshrc
