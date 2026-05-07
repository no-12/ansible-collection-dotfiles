[[ -z $TMUX ]] && [[ ! $TERM =~ screen ]] && [[ ! $TERM_PROGRAM =~ vscode ]] && exec tmux new -A -s main

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

{% if is_macos %}
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export PATH="$HOME/.local/bin:$PATH"
{% endif %}


################################
# zsh config
################################

autoload -Uz \
  compinit \
  down-line-or-beginning-search \
  run-help \
  up-line-or-beginning-search

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
  share_history

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

fpath=("{{ zsh_extensions_dir }}/gradle-completion" $fpath)


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
alias kc='HTTPS_PROXY=localhost:8888 kubectl'
alias ln='ln -v'
alias md='mkdir -pv'
alias rd='rmdir'
alias vi='vim'
alias gbc="git fetch -p; git branch -r | awk '{print \$1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print \$1}' | xargs git branch -d"
alias gbcf="git fetch -p; git branch -r | awk '{print \$1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print \$1}' | xargs git branch -D"

{% if is_macos %}
alias ls='ls -G'
{% else %}
alias ls='ls --color=auto'
{% endif %}

####################################
# Lazy loaders
####################################

# Schedule a command to run after the first prompt is drawn, without blocking
# it. Implemented via a self-feeding pipe whose zle -F handler fires once the
# event loop starts (i.e. after the prompt has been rendered).
typeset -ga _no12_deferred=()
_no12_defer() {
  _no12_deferred+=("$*")
  if [[ -z ${_no12_defer_fd-} ]]; then
    exec {_no12_defer_fd}< <(:)
    zle -F $_no12_defer_fd _no12_run_deferred
  fi
}
_no12_run_deferred() {
  zle -F $1
  exec {_no12_defer_fd}<&-
  unset _no12_defer_fd
  local cmd
  for cmd in "${_no12_deferred[@]}"; do
    eval "$cmd" 2>/dev/null
  done
  _no12_deferred=()
}

# Source `<bin> completion zsh` from a disk cache. Generating the script can
# be very slow (e.g. Docker Desktop's kubectl takes ~5s); caching keeps shell
# startup snappy, and stale caches are refreshed asynchronously after the
# first prompt rather than blocking it.
_no12_completion_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
_no12_load_completion() {
  local bin=$1
  hash $bin &> /dev/null || return
  local cache=$_no12_completion_cache_dir/${bin}.zsh
  local bin_path=${commands[$bin]}
  if [[ -s $cache ]]; then
    source $cache
    [[ $cache -ot $bin_path ]] && _no12_defer \
      "mkdir -p $_no12_completion_cache_dir && $bin completion zsh > $cache.tmp && mv $cache.tmp $cache"
  else
    _no12_defer \
      "mkdir -p $_no12_completion_cache_dir && $bin completion zsh > $cache.tmp && mv $cache.tmp $cache && source $cache"
  fi
}

####################################
# Source and configure other scripts
####################################

source "$HOME/.zsh_prompt.zsh"

[[ -s "$HOME/.fzfrc" ]] && source "$HOME/.fzfrc"

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

[[ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]] && source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
[[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]] && source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"

_no12_load_completion kubectl
_no12_load_completion op

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
