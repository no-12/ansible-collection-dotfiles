#!/usr/bin/env bash
source "venv/bin/activate"
declare ROLE_DIR
ROLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ansible-playbook \
  -v \
  --connection local \
  --inventory localhost, \
  --extra-vars "role_dir=$ROLE_DIR" \
  /dev/stdin <<EOF
---
- hosts: all
  vars:
    ansible_python_interpreter: python3
  roles:
    - role: "{{ role_dir }}"
EOF
