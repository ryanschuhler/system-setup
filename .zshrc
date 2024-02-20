export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
export PATH=$HOME/bin:/usr/local/bin:$PATH
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export ZSH=~/.oh-my-zsh

plugins=(git zsh-autosuggestions)
ZSH_THEME="minimal"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
DISABLE_UNTRACKED_FILES_DIRTY="true"

source $ZSH/oh-my-zsh.sh
source ~/.aliases
