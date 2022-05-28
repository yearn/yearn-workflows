docker build -t robowoofy:v0.0.1 --network=host -f build.Dockerfile .
az acr login --name robowoofyregistry
docker tag robowoofy:v0.0.1 robowoofyregistry.azurecr.io/robowoofy
docker push robowoofyregistry.azurecr.io/robowoofy