# example
VERSION=test
export CI=true
docker build -t robowoofy:$VERSION --network=host -f build.Dockerfile .
docker run -e ETHERSCAN_TOKEN -e CI --workdir /github/workspace -v "/home/listonjesse/strategist-ms/":"/github/workspace/" robowoofy:$VERSION main example eth