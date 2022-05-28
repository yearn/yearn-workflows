docker build -t robowoofy --network=host -f build.Dockerfile .
az acr login --name robowoofyregistry
docker tag robowoofy:latest robowoofyregistry.azurecr.io/robowoofy
docker push robowoofyregistry.azurecr.io/robowoofy