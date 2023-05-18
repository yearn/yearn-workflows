#!/bin/bash
ln -s /root/.solcx /github/home/.solcx
ln -s /root/.vvm /github/home/.vvm

pip install -r requirements-dev.txt
/root/.local/bin/brownie
cp network-config.yaml ~/.brownie/network-config.yaml
/root/.local/bin/brownie networks list true
brownie compile
python3 -m multisig_ci brownie run $1 $2 --network $3-main-fork 1>output.txt 2>error.txt
EXIT_CODE=$?
echo "brownie-exit-code=$EXIT_CODE" >> $GITHUB_OUTPUT

echo "::group:: Output"
cat output.txt
echo "::endgroup::"

echo "::group:: Error"
cat error.txt
echo "::endgroup::"

echo "nonce=$NONCE" >> $GITHUB_OUTPUT
echo "safe_link=$SAFE_LINK" >> $GITHUB_OUTPUT
echo "Action send is $GITHUB_ACTION_SEND"
echo "exit code is $EXIT_CODE"

if [[ "$GITHUB_ACTION_SEND" == "true" && "$NONCE" == "" ]]
then
    echo "error-reason='failed to find nonce'" >> $GITHUB_OUTPUT
    exit 1
elif [[ "$GITHUB_ACTION_SEND" == "true" && "$SAFE_LINK" == "" ]]
then
    echo "error-reason='failed to find safe link'" >> $GITHUB_OUTPUT
    exit 1
else
    exit $EXIT_CODE
fi