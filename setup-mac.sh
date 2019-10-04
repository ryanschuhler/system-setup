#!/bin/bash
# To install remotely run `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ryanschuhler/system-setup/master/setup-mac.sh)"`

# Install homebrew
xcode-select --install
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Apps
brew install curl git nodejs peco tig vim wget yank zsh
npm install -g gh gh-jira

wget https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg -P ~/Downloads/
open ~/Downloads/googlechrome.dmg
sudo cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/

wget https://download.docker.com/mac/stable/Docker.dmg -P ~/Downloads/
open ~/Downloads/Docker.dmg
sudo cp -r /Volumes/Docker.app /Applications/

wget https://downloads.slack-edge.com/mac_releases/Slack-4.0.3-macOS.dmg -P ~/Downloads/
open ~/Downloads/Slack-4.0.3-macOS.dmg
sudo cp -r /Volumes/Slack.app /Applications/

wget https://www.jetbrains.com/idea/download/download-thanks.html?platform=machttps://download-cf.jetbrains.com/idea/ideaIU-2019.2.3.dmg -P ~/Downloads/
open ~/Downloads/ideaIU-2019.2.3.dmg
sudo cp -r /Volumes/IntelliJ\ IDEA.app /Applications/

wget https://www.iterm2.com/nightly/latest -O ~/Downloads/iTerm.zip
unzip ~/Downloads/iTerm.zip
sudo cp -r ~/Downloads/iTerm.app /Applications/

wget https://github.com/ptsochantaris/trailer/releases/download/1.6.17/trailer1617.zip -P ~/Downloads/trailer.zip
unzip ~/Downloads/trailer.zip
sudo cp -r /Volumes/Trailer.app /Applications/

wget https://www.spotify.com/us/download/mac/ -P ~/Downloads/spotify.zip
unzip ~/Downloads/spotify.zip
open ~/Downloads/Install\ Spotify.app

open -a "Google Chrome" https://apps.apple.com/us/app/mail-for-gmail/id1216244845?mt=12

open -a "Google Chrome" https://apps.apple.com/us/app/magnet/id441258766?mt=12

open -a "Google Chrome" https://apps.apple.com/us/app/mini-calendar/id1088779979?mt=12

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
