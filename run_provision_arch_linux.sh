#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export ANSIBLE_COLLECTIONS_PATHS="$DIR":~/.ansible/collections:/usr/share/ansible/collections

ansible-playbook \
  -v \
  --connection local \
  --inventory "$(hostname)", \
  --ask-become-pass \
  no_12.dotfiles.provision_arch_linux
