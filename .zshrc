export ANT_OPTS=-Xmx2560m
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/1password/agent.sock
export ZSH=~/.oh-my-zsh

plugins=(
	git
	zsh-autosuggestions
	zsh-completions
	zsh-syntax-highlighting
)

DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="%T %d.%m.%y"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_THEME="minimal"

alias notes=~/.bash_apps/notes.sh
alias tasks=~/.bash_apps/tasks.sh

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt prompt_subst

function execute_gradlew {
	if [ -e gradlew ]
	then
		./gradlew ${@}
	elif [ -e ../gradlew ]
	then
		../gradlew ${@}
	elif [ -e ../../gradlew ]
	then
		../../gradlew ${@}
	elif [ -e ../../../gradlew ]
	then
		../../../gradlew ${@}
	elif [ -e ../../../../gradlew ]
	then
		../../../../gradlew ${@}
	elif [ -e ../../../../../gradlew ]
	then
		../../../../../gradlew ${@}
	elif [ -e ../../../../../../gradlew ]
	then
		../../../../../../gradlew ${@}
	elif [ -e ../../../../../../../gradlew ]
	then
		../../../../../../../gradlew ${@}
	elif [ -e ../../../../../../../../gradlew ]
	then
		../../../../../../../../gradlew ${@}
	elif [ -e ../../../../../../../../../gradlew ]
	then
		../../../../../../../../../gradlew ${@}
	else
		echo "Unable to find locate Gradle wrapper."
	fi
}

function gw {
	execute_gradlew "${@//\//:}" --daemon
}

source $ZSH/oh-my-zsh.sh

PROMPT='%2/ $(git_prompt_info)> '
