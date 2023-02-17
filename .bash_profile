#   Change Prompt
#   ------------------------------------------------------------
    prompt_color_purple="\[\e[1;35m\]"
    prompt_color_reset="\[\e[0m\]"
    prompt_color_teal="\[\e[0;36m\]"

    parse_git_branch() {
         git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    }

    export PS1="________________________________________________________________________________\n| ${prompt_color_purple}\w ${prompt_color_teal}\$(parse_git_branch) ${prompt_color_reset}=> \n| => "
    export PS2="| => "
export PATH="$PATH:$HOME/Library/PackageManager/bin"
