#!/usr/bin/env bash
set -eu

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export ANSIBLE_COLLECTIONS_PATHS="$DIR":~/.ansible/collections:/usr/share/ansible/collections

ansible-playbook \
  -vv \
  --connection local \
  --inventory "$1", \
  --ask-become-pass \
  no_12.dotfiles.provision
