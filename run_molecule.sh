#!/usr/bin/env bash
set -e
source ".python_venv/bin/activate"
molecule test
