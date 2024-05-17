export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
export PATH=$HOME/bin:/usr/local/bin:$HOME/Library/PackageManager/bin:$PATH
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export ZSH=~/.oh-my-zsh
export ANT_OPTS=-Xmx2560m

plugins=(
    git
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
)

ZSH_THEME="minimal"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
DISABLE_UNTRACKED_FILES_DIRTY="true"

HISTFILE="$HOME/.zsh_history"
# Display timestamps for each command
HIST_STAMPS="%T %d.%m.%y"

HISTSIZE=10000000
SAVEHIST=10000000

# Ignore these commands in history
HISTORY_IGNORE="(ls|pwd|cd)*"

# Write the history file in the ':start:elapsed;command' format.
setopt EXTENDED_HISTORY

# Do not record an event starting with a space.
setopt HIST_IGNORE_SPACE

# Don't store history commands
setopt HIST_NO_STORE

source $ZSH/oh-my-zsh.sh
source ~/.aliases
