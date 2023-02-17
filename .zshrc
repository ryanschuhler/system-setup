# export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH=~/.oh-my-zsh

ZSH_THEME="eastwood"

plugins=(git zsh-autosuggestions)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'

source $ZSH/oh-my-zsh.sh

. ~/.aliases
export ANT_OPTS=-Xmx2560m
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
export PATH=$PATH:$HOME/Library/PackageManager/bin
