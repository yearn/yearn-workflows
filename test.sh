# example
VERSION=test
docker build -t robowoofy:$VERSION --network=host -f build.Dockerfile .
docker run -e ETHERSCAN_TOKEN --workdir /github/workspace -v "/home/listonjesse/strategist-ms/":"/github/workspace/" robowoofy:$VERSION main example eth
docker run -it --entrypoint bash -e ETHERSCAN_TOKEN --workdir /github/workspace -v "/home/listonjesse/strategist-ms/":"/github/workspace/" robowoofy:$VERSION