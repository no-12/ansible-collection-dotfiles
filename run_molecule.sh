#!/usr/bin/env bash
set -e

if [[ ! -d venv ]]; then
    python3 -m venv venv
fi
source "venv/bin/activate"
pip install --upgrade pip setuptools molecule docker ansible-lint
molecule test
