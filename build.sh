docker build -t robowoofy:upgrade --network=host -f build.Dockerfile .
az acr login --name robowoofyregistry
docker tag robowoofy:upgrade robowoofyregistry.azurecr.io/robowoofy:upgrade
docker push robowoofyregistry.azurecr.io/robowoofy:upgrade