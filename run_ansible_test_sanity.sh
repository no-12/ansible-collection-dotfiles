#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export PYTHON_VERSION="$(python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))')"
export ANSIBLE_COLLECTIONS_PATHS="$DIR":~/.ansible/collections:/usr/share/ansible/collections

cd "$DIR/ansible_collections/no_12/dotfiles" && ansible-test sanity --python "$PYTHON_VERSION"
