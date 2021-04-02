#!/usr/bin/env bash
set -e
if [[ ! -d .python_venv ]]; then
    python3 -m venv .python_venv
fi
source ".python_venv/bin/activate"
pip install --upgrade pip setuptools ansible ansible-lint docker molecule
