# Ansible role for custom dotfiles
## Setup python virtual environment
There is an .envrc file to setup a python virtual environment with all required packages with [direnv](https://direnv.net/). The [requirements](./requirements.txt) can be installed manually with `pip install --requirement requirements.txt`
## Run locally
```sh
./run_role_locally.sh
```
## Run tests
```sh
molecule test
```
