# inspired by devcontainers common-utils / robbyrussell-style prompts
# https://github.com/devcontainers/features/blob/main/src/common-utils/scripts/bash_theme_snippet.sh
# which is inspired by/based on: https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/robbyrussell.zsh-theme

__dc_git_branch() {
    if [ "$(git config --get devcontainers-theme.hide-status 2>/dev/null)" = 1 ] ||
       [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" = 1 ]; then
        return
    fi

    local branch dirty=""
    branch="$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null ||
              git --no-optional-locks rev-parse --short HEAD 2>/dev/null)" || return

    [ -n "$branch" ] || return

    if [ "$(git config --get devcontainers-theme.show-dirty 2>/dev/null)" = 1 ] &&
       git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" >/dev/null 2>&1; then
        dirty=" \[\033[1;33m\]✗"
    fi

    printf '\[\033[0;36m\](\[\033[1;31m\]%s%s\[\033[0;36m\]) ' "$branch" "$dirty"
}

__dc_set_ps1() {
    local xit=$?
    local green='\[\033[0;32m\]'
    local blue='\[\033[1;34m\]'
    local red='\[\033[1;31m\]'
    local reset='\[\033[0m\]'
    local userpart arrow gitpart

    if [ -n "${GITHUB_USER:-}" ]; then
        userpart="${green}@${GITHUB_USER} "
    else
        userpart="${green}\u "
    fi

    if [ "$xit" -ne 0 ]; then
        arrow="${red}➜"
    else
        arrow="${reset}➜"
    fi

    gitpart="$(__dc_git_branch)"
    PS1="${userpart}${arrow} ${blue}\w ${gitpart}${reset}\$ "
}

PROMPT_DIRTRIM=4
PROMPT_COMMAND="__dc_set_ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

__dc_supports_title() {
    case "${TERM:-}" in
        xterm*|screen*|tmux*|rxvt*|alacritty*|foot*|kitty*) return 0 ;;
        *) return 1 ;;
    esac
}

if [[ $- == *i* ]] && __dc_supports_title; then
    __dc_preexec() {
        printf '\033]0;%s@%s: %s\007' "$USER" "${HOSTNAME%%.*}" "${BASH_COMMAND}"
    }

    __dc_precmd() {
        printf '\033]0;%s@%s: %s\007' "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"
    }

    trap '__dc_preexec' DEBUG
    PROMPT_COMMAND="__dc_precmd${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
