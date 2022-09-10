VERSION=test
export CI=true
docker build -t robowoofy:$VERSION --network=host -f Dockerfile .
docker run -it --entrypoint bash -e ETHERSCAN_TOKEN -e CI --workdir /github/workspace -v "/home/listonjesse/strategist-ms/":"/github/workspace/" robowoofy:$VERSION