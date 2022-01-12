#!/usr/bin/env bash
set -eu

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export ANSIBLE_COLLECTIONS_PATHS="$DIR":~/.ansible/collections:/usr/share/ansible/collections

ASK_BECOME_PASS=""
if [ "$(uname)" != "Darwin" ]; then
  ASK_BECOME_PASS="--ask-become-pass"
fi

ansible-playbook \
  -vv \
  --connection local \
  --inventory "$1", \
  $ASK_BECOME_PASS \
  no_12.dotfiles.provision
