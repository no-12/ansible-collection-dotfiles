# Custom prompt — replaces powerlevel10k.
# Powerline-style segments rendered with a Nerd Font.
#   Left:  cwd, git branch (yellow=clean, blue=dirty)
#   Right: python venv (always); kube context and gcloud project shown
#          only while the command being typed uses them.

autoload -Uz add-zsh-hook add-zle-hook-widget vcs_info
setopt prompt_subst

# Powerline separators (require a Nerd Font)
typeset -g _NO12_LSEP=$''
typeset -g _NO12_RSEP=$''

# Icons (Nerd Font)
typeset -g _NO12_GIT_ICON=$''
typeset -g _NO12_PY_ICON=$''
typeset -g _NO12_K8S_ICON=$'☸'
typeset -g _NO12_GCP_ICON=$'☁'

# Segment colors (256-color indices, mirroring the former .p10k.zsh look)
typeset -g _NO12_DIR_BG=2 _NO12_DIR_FG=0
typeset -g _NO12_GIT_CLEAN_BG=3 _NO12_GIT_DIRTY_BG=4 _NO12_GIT_FG=0
typeset -g _NO12_VENV_BG=6 _NO12_VENV_FG=0
typeset -g _NO12_K8S_BG=5 _NO12_K8S_FG=0
typeset -g _NO12_GCP_BG=4 _NO12_GCP_FG=0

# Commands whose presence in the input line surfaces the matching segment.
typeset -ga _NO12_KUBE_CMDS=(kubectl kc helm k9s kubectx kubens stern kustomize)
typeset -ga _NO12_GCP_CMDS=(gcloud gsutil bq)

# vcs_info: msg_0_ = branch, msg_1_ = dirty marker (empty when clean).
# Splitting them avoids false positives when a branch name contains '+' or '*'.
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes false
zstyle ':vcs_info:git:*' stagedstr   '+'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats       '%b' '%c%u'
zstyle ':vcs_info:git:*' actionformats '%b|%a' '%c%u'

# Cached per-command values (refreshed in precmd, consumed by render).
typeset -g _NO12_DIR_DISP=""
typeset -g _NO12_BRANCH=""
typeset -g _NO12_BRANCH_DIRTY=""
typeset -g _NO12_VENV_NAME=""
typeset -g _NO12_KUBE_CTX=""
typeset -g _NO12_GCP_PROJ=""
typeset -g _NO12_PROMPT_CACHE=""

_no12_kube_ctx() {
  local f=${KUBECONFIG:-$HOME/.kube/config}
  [[ -r $f ]] || return
  awk '/^current-context:/ {print $2; exit}' $f 2>/dev/null
}

_no12_gcloud_project() {
  local active=$HOME/.config/gcloud/active_config
  [[ -r $active ]] || return
  local cfg
  read -r cfg < $active
  local f=$HOME/.config/gcloud/configurations/config_$cfg
  [[ -r $f ]] || return
  awk -F'[[:space:]]*=[[:space:]]*' '/^project[[:space:]]*=/ {print $2; exit}' $f 2>/dev/null
}

# Sets show_kube / show_gcp in the caller scope based on the current ZLE buffer.
_no12_buffer_flags() {
  show_kube=0
  show_gcp=0
  local buffer=${BUFFER:-}
  [[ -z $buffer ]] && return
  local words
  words=(${(z)buffer})
  local w
  for w in $words; do
    (( ${_NO12_KUBE_CMDS[(Ie)$w]} )) && show_kube=1
    (( ${_NO12_GCP_CMDS[(Ie)$w]}  )) && show_gcp=1
  done
}

_no12_render() {
  local show_kube show_gcp
  _no12_buffer_flags

  # ── LEFT ─────────────────────────────────────────────────────────
  local lprompt="" prev_bg=""
  integer lvlen=0

  local dir_safe=${_NO12_DIR_DISP//\%/%%}
  lprompt+="%K{$_NO12_DIR_BG}%F{$_NO12_DIR_FG} $dir_safe %k"
  (( lvlen += ${#_NO12_DIR_DISP} + 2 ))
  prev_bg=$_NO12_DIR_BG

  if [[ -n $_NO12_BRANCH ]]; then
    local branch_safe=${_NO12_BRANCH//\%/%%}
    local git_bg=$_NO12_GIT_CLEAN_BG
    [[ -n $_NO12_BRANCH_DIRTY ]] && git_bg=$_NO12_GIT_DIRTY_BG
    local content="$_NO12_GIT_ICON $branch_safe"
    lprompt+="%K{$git_bg}%F{$prev_bg}$_NO12_LSEP%F{$_NO12_GIT_FG} $content %k"
    (( lvlen += ${#_NO12_GIT_ICON} + 1 + ${#_NO12_BRANCH} + 3 ))
    prev_bg=$git_bg
  fi

  lprompt+="%F{$prev_bg}$_NO12_LSEP%f"
  (( lvlen += 1 ))

  # ── RIGHT ────────────────────────────────────────────────────────
  local rprompt=""
  integer rvlen=0
  integer first=1
  prev_bg=""

  _no12_right_seg() {
    local bg=$1 fg=$2 content=$3
    local content_safe=${content//\%/%%}
    if (( first )); then
      rprompt+="%F{$bg}$_NO12_RSEP%K{$bg}%F{$fg} $content_safe %f%k"
      first=0
    else
      rprompt+="%K{$prev_bg}%F{$bg}$_NO12_RSEP%K{$bg}%F{$fg} $content_safe %f%k"
    fi
    (( rvlen += ${#content} + 3 ))
    prev_bg=$bg
  }

  if (( show_kube )) && [[ -n $_NO12_KUBE_CTX ]]; then
    _no12_right_seg $_NO12_K8S_BG $_NO12_K8S_FG "$_NO12_K8S_ICON $_NO12_KUBE_CTX"
  fi
  if (( show_gcp )) && [[ -n $_NO12_GCP_PROJ ]]; then
    _no12_right_seg $_NO12_GCP_BG $_NO12_GCP_FG "$_NO12_GCP_ICON $_NO12_GCP_PROJ"
  fi
  if [[ -n $_NO12_VENV_NAME ]]; then
    _no12_right_seg $_NO12_VENV_BG $_NO12_VENV_FG "$_NO12_PY_ICON $_NO12_VENV_NAME"
  fi

  unfunction _no12_right_seg

  # ── COMPOSE ──────────────────────────────────────────────────────
  if (( rvlen > 0 )); then
    integer pad=$(( COLUMNS - lvlen - rvlen ))
    (( pad < 1 )) && pad=1
    local spacer
    spacer=$(printf '%*s' $pad '')
    PROMPT=$'\n'"${lprompt}${spacer}${rprompt}"$'\n''%(?.%F{2}.%F{1})❯%f '
  else
    PROMPT=$'\n'"${lprompt}"$'\n''%(?.%F{2}.%F{1})❯%f '
  fi
  RPROMPT=""
}

_no12_precmd() {
  vcs_info

  _NO12_DIR_DISP=${(%):-%~}
  _NO12_BRANCH=$vcs_info_msg_0_
  _NO12_BRANCH_DIRTY=$vcs_info_msg_1_

  _NO12_VENV_NAME=""
  if [[ -n $VIRTUAL_ENV ]]; then
    local v=${VIRTUAL_ENV:t}
    [[ $v == (.venv|venv|env) ]] && v=${VIRTUAL_ENV:h:t}
    _NO12_VENV_NAME=$v
  fi

  _NO12_KUBE_CTX=$(_no12_kube_ctx)
  _NO12_GCP_PROJ=$(_no12_gcloud_project)

  _no12_render
  _NO12_PROMPT_CACHE=$PROMPT
}

# Re-render on every buffer change so kube/gcloud appear/disappear as you type.
# zle-line-pre-redraw on its own only repaints the input line, not the prompt
# area — to actually swap segments we have to call reset-prompt. The cache
# guard breaks the recursion (reset-prompt re-fires this hook).
_no12_zle_redraw() {
  _no12_render
  if [[ $PROMPT != $_NO12_PROMPT_CACHE ]]; then
    _NO12_PROMPT_CACHE=$PROMPT
    zle .reset-prompt
  fi
}

add-zsh-hook precmd _no12_precmd
add-zle-hook-widget line-pre-redraw _no12_zle_redraw
