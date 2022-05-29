docker build -t robowoofy:v0.0.9 --network=host -f build.Dockerfile .
az acr login --name robowoofyregistry
docker tag robowoofy:v0.0.9 robowoofyregistry.azurecr.io/robowoofy:v0.0.9
docker push robowoofyregistry.azurecr.io/robowoofy:v0.0.9