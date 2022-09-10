#!/bin/bash
echo $HOME
export PATH=/home/pn/.local/bin:${PATH}
export VVM_BINARY_PATH=/home/pn/.vvm
export SOLCX_BINARY_PATH=/home/pn/.solcx

VIRTUAL_ENV=/home/pn/.local/pipx/venvs
python3 -m venv $VIRTUAL_ENV
PATH="$VIRTUAL_ENV/bin:$PATH"
mkdir ~/.brownie
cp network-config.yaml ~/.brownie/network-config.yaml
brownie version