docker build -t robowoofy:v0.0.11 --network=host -f build.Dockerfile .
az acr login --name robowoofyregistry
docker tag robowoofy:v0.0.11 robowoofyregistry.azurecr.io/robowoofy:v0.0.11
docker push robowoofyregistry.azurecr.io/robowoofy:v0.0.11