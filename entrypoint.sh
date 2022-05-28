#!/bin/bash
echo $HOME
export PATH=/home/pn/.local/bin:${PATH}
export PATH=/github/home/.local/bin:${PATH}

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

#sudo chown -R 1000:1000 ~/.brownie/deployments.db

python3 -m multisig_ci brownie run $1 $2 --network $3-main-fork
EXIT_CODE=$?
echo "::set-output name=brownie-exit-code::$EXIT_CODE"
cat $HOME/nonce.txt
cat $HOME/safe.txt
NONCE=$(cat $HOME/nonce.txt)
SAFE_LINK=$(cat $HOME/safe.txt)

echo "::set-output name=nonce::$NONCE"
echo "::set-output name=safe_link::$SAFE_LINK"
echo "github action send is $GITHUB_ACTION_SEND"
echo "nonce is $NONCE"
echo "safe link is $SAFE_LINK"
echo "exit code is $EXIT_CODE"

if [[ "$GITHUB_ACTION_SEND" == "true" && "$NONCE" == "" ]]
then
    echo "::set-output name=error-reason::'failed to find nonce'"
    exit 1
elif [[ "$GITHUB_ACTION_SEND" == "true" && "$SAFE_LINK" == "" ]]
then
    echo "::set-output name=error-reason::'failed to find safe link'"
    exit 1
else
    echo "Exiting with $EXIT_CODE"
    exit $EXIT_CODE
fi