# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

################################
# Environment variables
################################

DIRSTACKSIZE=16
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=$HISTSIZE

# Colors
black='\e[0;30m'
BLACK='\e[1;30m'
red='\e[0;31m'
RED='\e[1;31m'
green='\e[0;32m'
GREEN='\e[1;32m'
yellow='\e[0;33m'
YELLOW='\e[1;33m'
blue='\e[0;34m'
BLUE='\e[1;34m'
purple='\e[0;35m'
PURPLE='\e[1;35m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
white='\e[0;37m'
WHITE='\e[1;37m'
NC='\e[0m'


################################
# zsh config
################################

autoload -Uz \
  compinit \
  down-line-or-beginning-search \
  run-help \
  up-line-or-beginning-search \

compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

unsetopt \
  flowcontrol \
  menu_complete \

setopt \
  always_to_end \
  auto_menu \
  auto_pushd \
  complete_in_word \
  extended_glob \
  extended_history \
  hist_expire_dups_first \
  hist_ignore_dups \
  hist_ignore_space \
  hist_reduce_blanks \
  hist_verify \
  pushd_ignore_dups \
  pushd_minus \
  pushd_silent \
  pushd_to_home \
  share_history \


################################
# Functions
################################

# Looks for a gradlew file in the current working directory
# or any of its parent directories, and executes it if found.
# Otherwise it will call gradle directly.
gradle-or-gradlew() {
  # find project root
  # taken from https://github.com/gradle/gradle-completion
  local dir="$PWD" project_root="$PWD"
  while [[ "$dir" != / ]]; do
    if [[ -f "$dir/settings.gradle" || -f "$dir/settings.gradle.kts" || -f "$dir/gradlew" ]]; then
      project_root="$dir"
      break
    fi
    dir="${dir:h}"
  done

  # if gradlew found, run it instead of gradle
  if [[ -f "$project_root/gradlew" ]]; then
    echo "executing gradlew instead of gradle"
    "$project_root/gradlew" "$@"
  else
    command gradle "$@"
  fi
}

ranger() {
  if [ -z "$RANGER_LEVEL" ]; then
    /usr/bin/ranger "$@"
  else
    exit
  fi
}

cdParent() {
  if [[ -z $BUFFER ]]; then
    pushd ..
    zle accept-line
  fi
}

cdRecent() {
  if [[ -z $BUFFER ]] && [[ ${#$(dirs)} -gt 1 ]]; then
    pushd -
    zle accept-line
  fi
}

cdUndo() {
  if [[ -z $BUFFER ]] && [[ ${#$(dirs)} -gt 1 ]]; then
    popd
    zle accept-line
  fi
}

precmd() {
  print -Pn "\e]0;[%n@%M]: %~\a"
}

preexec() {
  print -Pn "\e]0;[%n@%M]: %~ - $1\a"
}

zle -N cdParent
zle -N cdRecent
zle -N cdUndo

zle -N down-line-or-beginning-search
zle -N up-line-or-beginning-search


################################
# Key bindings
################################

typeset -g -A key
key[Alt-Delete]='^[[3;3~'
key[Alt-Left]='^[[1;3D'
key[Alt-Right]='^[[1;3C'
key[Ctrl-Down]='^[[1;5B'
key[Ctrl-Left]='^[[1;5D'
key[Ctrl-Up]='^[[1;5A'
key[Delete]="${terminfo[kdch1]}"
key[Down]="${terminfo[kcud1]}"
key[End]="${terminfo[kend]}"
key[Home]="${terminfo[khome]}"
key[Insert]="${terminfo[kich1]}"
key[PageDown]="${terminfo[knp]}"
key[PageUp]="${terminfo[kpp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Up]="${terminfo[kcuu1]}"

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

bindkey "${key[Alt-Delete]}" kill-word
bindkey "${key[Alt-Left]}" backward-word
bindkey "${key[Alt-Right]}" forward-word
bindkey "${key[Ctrl-Down]}" cdRecent
bindkey "${key[Ctrl-Left]}" cdUndo
bindkey "${key[Ctrl-Up]}" cdParent
bindkey "${key[Delete]}" delete-char
bindkey "${key[Down]}" down-line-or-beginning-search
bindkey "${key[End]}" end-of-line
bindkey "${key[Home]}" beginning-of-line
bindkey "${key[Insert]}" overwrite-mode
bindkey "${key[PageDown]}" down-line-or-history
bindkey "${key[PageUp]}" up-line-or-history
bindkey "${key[Shift-Tab]}" reverse-menu-complete
bindkey "${key[Up]}" up-line-or-beginning-search

fpath=("${HOME}/.zsh/gradle-completion" $fpath)


################################
# Aliases
################################

(( ${+aliases[run-help]} )) && unalias run-help

alias ackn='ack --nopager'
alias cp='cp -v'
alias d='dirs -v'
alias g='git'
alias gradle=gradle-or-gradlew
alias grep='grep --color=auto'
alias h='history'
alias help='run-help'
alias history='fc -Dil'
alias l='ls -ahl'
alias ln='ln -v'
alias md='mkdir -pv'
alias mv='mv -v'
alias rd='rmdir'
alias rm='rm -v'
alias vi='vim'

case "$OSTYPE" in
  darwin*)
    alias ls='ls -G'
  ;;
  linux*)
    alias ls='ls --color=auto'
  ;;
esac


################################
# Source other scripts
################################

# fzf
source "$HOME/.fzfrc"

# termite: enable ctrl-shift-t to open terminal in the current directory
if [[ $VTE_VERSION ]]; then
  source /etc/profile.d/vte.sh
  __vte_osc7
fi

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats "%b %m%u%c"

precmd() {
  vcs_info

  local host_info=""
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    host_info="[%m]:"
  fi

  PS1="%(?.%K{green}%F{black}.%B%F{yellow}%K{red} ✘ %? %b%F{red}%K{green}%F{black})%B$host_info %~ %b%f%k"
  local previous_bg_color=green

  if [ ! -z ${vcs_info_msg_0_} ]; then
    PS1+="%F{$previous_bg_color}%K{yellow}%F{black}  $vcs_info_msg_0_ %f%k"
    previous_bg_color=yellow
  fi

  if [ ! -z $VIRTUAL_ENV ]; then
    PS1+="%F{$previous_bg_color}%K{blue}%F{black}  $(basename $VIRTUAL_ENV) %f%k"
    previous_bg_color=blue
  fi

  PS1+="%F{$previous_bg_color}%k%f"$'\n%(!.#.❯) '
}

# source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
