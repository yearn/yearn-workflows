#!/bin/bash
ln -s /root/.solcx /github/home/.solcx
ln -s /root/.vvm /github/home/.vvm

sudo pip install -r requirements-dev.txt
brownie
cp network-config.yaml ~/.brownie/network-config.yaml
brownie networks list true
brownie compile
python3 -m multisig_ci brownie run $1 $2 --network $3-main-fork 1>output.txt 2>error.txt
EXIT_CODE=$?
echo "::set-output name=brownie-exit-code::$EXIT_CODE"

echo "::group:: Output"
cat output.txt
echo "::endgroup::"

echo "::group:: Error"
cat error.txt
echo "::endgroup::"

echo "::set-output name=nonce::$NONCE"
echo "::set-output name=safe_link::$SAFE_LINK"
echo "Action send is $GITHUB_ACTION_SEND"
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
    exit $EXIT_CODE
fi