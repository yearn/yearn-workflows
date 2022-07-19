docker build -t robowoofy:weiroll --network=host -f build.Dockerfile .
az acr login --name robowoofyregistry
docker tag robowoofy:weiroll robowoofyregistry.azurecr.io/robowoofy:weiroll
docker push robowoofyregistry.azurecr.io/robowoofy:weiroll