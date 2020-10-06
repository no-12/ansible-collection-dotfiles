#!/usr/bin/env bash
ROLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
EXTRA_ARGS=(--skip-tags install_packages)

print_usage() {
  echo "Usage:"
  echo "    ${BASH_SOURCE[0]} -h        Display this help message."
  echo "    ${BASH_SOURCE[0]} -p        Install packages (requires sudo)"
}

while getopts "hp" opt; do
  case ${opt} in
  h) print_usage && exit 0 ;;
  p) EXTRA_ARGS=(--ask-become-pass) ;;
  *) print_usage exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [[ "$OSTYPE" == "darwin"* ]]; then
  EXTRA_ARGS=(--)
fi

source "venv/bin/activate"

ansible-playbook \
  -v \
  --connection local \
  --inventory localhost, \
  --extra-vars "role_dir=$ROLE_DIR" \
  "${EXTRA_ARGS[@]}" \
  /dev/stdin <<EOF
---
- hosts: all
  vars:
    ansible_python_interpreter: python3
  roles:
    - role: "{{ role_dir }}"
EOF
