################################
# Environment variables
################################
DEFAULT_USER="$(whoami)"
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

{% if ansible_system == 'Darwin' %}
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
{% endif %}


################################
# zsh config
################################

autoload -Uz \
  compinit \
  down-line-or-beginning-search \
  run-help \
  up-line-or-beginning-search \
  vcs_info \
  add-zsh-hook

compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats "%b %c%u"
zstyle ':vcs_info:*' actionformats "%b %F{red}(%a)%f %c%u"
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr '±'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-stashed

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
  share_history

_vbe_vcs_info() {
    cd -q $1
    vcs_info
    print ${vcs_info_msg_0_}
}

source $HOME/async.zsh
async_init
async_start_worker vcs_info
async_register_callback vcs_info _vbe_vcs_info_done

_vbe_vcs_info_done() {
    local stdout=$3
    vcs_info_msg_0_=$stdout

      PS1=""

  if [[ "$EUID" -eq 0 || "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    PS1+="%(!.%K{red} %n@%m %F{red}.%K{black} %n@%m %F{black})%K{green}%k"
  fi

  PS1+="%F{black}%K{green} %~ %f%k"
  local previous_bg_color=green

  if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
    PS1+="%F{$previous_bg_color}%K{yellow}%F{black}  ${vcs_info_msg_0_} %f%k"
    previous_bg_color=yellow
  fi

  if [ ! -z $VIRTUAL_ENV ]; then
    PS1+="%F{$previous_bg_color}%K{blue}%f  $(basename $VIRTUAL_ENV) %k"
    previous_bg_color=blue
  fi

  PS1+="%F{$previous_bg_color}%k%f"
  PS1+=$'\n%(?.%F{green}.%F{red})%(!.#.❯)%f '

    zle reset-prompt
}

_vbe_vcs_precmd() {
    async_flush_jobs vcs_info
    async_job vcs_info _vbe_vcs_info $PWD
}

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
  if [[ -z $BUFFER ]] && [[ {% raw %}${#$(dirs)[@]}{% endraw %} -gt 1 ]]; then
    pushd -
    zle accept-line
  fi
}

cdUndo() {
  if [[ -z $BUFFER ]] && [[ {% raw %}${#$(dirs)[@]}{% endraw %} -gt 1 ]]; then
    popd
    zle accept-line
  fi
}

+vi-git-untracked(){
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
    git status --porcelain | grep '??' &> /dev/null ; then
    hook_com[unstaged]+='^'
  fi
}

+vi-git-stashed() {
  if git rev-parse --verify refs/stash &>/dev/null ; then
    hook_com[unstaged]+='*'
  fi
}

precmd() {
  async_flush_jobs vcs_info
  async_job vcs_info _vbe_vcs_info $PWD

  # set terminal window title
  print -Pn "\e]0;[%n@%m]: %~\a"

  PS1=""

  if [[ "$EUID" -eq 0 || "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    PS1+="%(!.%K{red} %n@%m %F{red}.%K{black} %n@%m %F{black})%K{green}%k"
  fi

  PS1+="%F{black}%K{green} %~ %f%k"
  local previous_bg_color=green

  if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
    PS1+="%F{$previous_bg_color}%K{yellow}%F{black}  ${vcs_info_msg_0_} %f%k"
    previous_bg_color=yellow
  fi

  if [ ! -z $VIRTUAL_ENV ]; then
    PS1+="%F{$previous_bg_color}%K{blue}%f  $(basename $VIRTUAL_ENV) %k"
    previous_bg_color=blue
  fi

  PS1+="%F{$previous_bg_color}%k%f"
  PS1+=$'\n%(?.%F{green}.%F{red})%(!.#.❯)%f '
}

preexec() {
  # set terminal window title to current command
  print -Pn "\e]0;[%n@%m]: %~ - $1\a"
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
alias rd='rmdir'
alias vi='vim'

{% if ansible_system == 'Darwin' %}
alias ls='ls -G'
{% else %}
alias ls='ls --color=auto'
{% endif %}

################################
# Source other scripts
################################

[[ -f "$HOME/.fzfrc" ]] && source "$HOME/.fzfrc"

[[ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
[[ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]] && source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

hash direnv &> /dev/null && eval "$(direnv hook zsh)" || true

[[ ! $TERM =~ screen ]] && [[ ! $TERM_PROGRAM =~ vscode ]] && exec tmux new -A -s main
