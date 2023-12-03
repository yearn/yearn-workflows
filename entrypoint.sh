#!/bin/bash
echo $HOME
export PATH=/home/pn/.local/bin:${PATH}
export PATH=/github/home/.local/bin:${PATH}
export PATH=/home/pn/.foundry/bin:${PATH}

sudo chown -R 1000:1000 /github/workspace
sudo chown -R 1000:1000 /github/home
sudo chown -R 1000:1000 /github/file_commands

export VVM_BINARY_PATH=/home/pn/.vvm
export SOLCX_BINARY_PATH=/home/pn/.solcx

VIRTUAL_ENV=/home/pn/.local/pipx/venvs
python3 -m venv $VIRTUAL_ENV
PATH="$VIRTUAL_ENV/bin:$PATH"

mkdir ~/.brownie
cp network-config.yaml ~/.brownie/network-config.yaml

if [[ -f "$HOME/.brownie/deployments.db" ]]; then
    echo "Brownie db already exists"
    du ~/.brownie/deployments.db
else
    echo "Linking brownie db"
    ln -s /home/pn/deployments.db ~/.brownie/deployments.db
    du ~/.brownie/deployments.db
    du /home/pn/deployments.db
fi

python3 -m multisig_ci brownie run $1 $2 --network $3-main-fork 1>output.txt 2>error.txt || EXIT_CODE=$?
echo "brownie-exit-code=$EXIT_CODE" >> $GITHUB_OUTPUT
echo "::group:: Output"
cat output.txt
echo "::endgroup::"
echo "::group:: Error"
cat error.txt
echo "::endgroup::"


NONCE=$(cat $HOME/nonce.txt)
SAFE_LINK=$(cat $HOME/safe.txt)

echo "nonce=$NONCE" >> $GITHUB_OUTPUT
echo "safe_link=$SAFE_LINK" >> $GITHUB_OUTPUT

if [[ "$GITHUB_ACTION_SEND" == "true" && "$NONCE" == "" ]]; then
    echo "error-reason='failed to find nonce'" >> $GITHUB_OUTPUT
    exit 1
elif [[ "$GITHUB_ACTION_SEND" == "true" && "$SAFE_LINK" -eq "" ]]; then
    echo "error-reason='failed to find safe link'" >> $GITHUB_OUTPUT
    exit 1
else
    echo "Exiting with $EXIT_CODE"
    exit $EXIT_CODE
fi
