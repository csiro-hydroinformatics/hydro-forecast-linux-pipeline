# Docker image for HYDROFC CI

## Getting our base image for CI

An image is available on docker-registry.it.csiro.au from the [hydrofc/ubuntu-jammy-202310 project on the CSIRO Harbor server](https://docker-registry.it.csiro.au/harbor/projects/335/repositories/ubuntu-jammy-202310)

```sh
TAG="20231025"
docker pull docker-registry.it.csiro.au/hydrofc/ubuntu-jammy-202310:${TAG}
```

```sh
docker run docker-registry.it.csiro.au/hydrofc/ubuntu-jammy-202310:${TAG}
```

## Housekeeping

```sh
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker images | grep jammy
```

`docker rmi --force 0526885ade32 e0688f546f0c e4c58958181a` seems not to work. Trying `docker image prune -a` instead of `docker rmi --force` thinking this will let me remove some images and intermadiaries... but no, it nukes everything.

## Building

```sh
TARGET=ubuntu-jammy-202310
DOCKER_REPOSITORY=hydrofc
IMAGE_NAME=ubuntu-jammy-202310
TAG=`date +%Y%m%d`
EXTRA_ARGS=""

# to clean up:
# docker rmi --force ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG}

# can use --no-cache:
# EXTRA_ARGS="--no-cache"
cd ${HOME}/src/hydro-fc-packaging/images
docker build  \
  -f Dockerfile-jammy-base \
  --target ${TARGET}  \
  --squash \
  --tag ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG} ${EXTRA_ARGS}  \
  --progress=plain . 2>&1 | tee build-${IMAGE_NAME}.log
```

```sh
docker tag ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG} docker-registry.it.csiro.au/hydrofc/${IMAGE_NAME}:${TAG}
docker tag ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG} sfforecastingctnrregistry.azurecr.io/${IMAGE_NAME}:${TAG}
```

```sh
docker push docker-registry.it.csiro.au/hydrofc/${IMAGE_NAME}:${TAG}
```

And to push to the azure container:

```sh
. $HOME/credentials/secrets/az_pat
az login

az account set --subscription $SUBSCRIPTION_ID 
az acr login --name sfforecastingctnrregistry

docker push sfforecastingctnrregistry.azurecr.io/${IMAGE_NAME}:${TAG}
```

## docker

```sh
TAG="20231025"
TARGET=ubuntu-jammy-202310
DOCKER_REPOSITORY=hydrofc
IMAGE_NAME=ubuntu-jammy-202310
EXTRA_ARGS=""

docker tag ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG} disparue/${IMAGE_NAME}:${TAG}

docker login -u disparue
docker push disparue/${IMAGE_NAME}:${TAG}

```

## Troubleshooting

```text
unauthorized: unauthorized to access repository: hydrofc/ubuntu-jammy-202310, action: push: unauthorized to access repository: hydrofc/ubuntu-jammy-202310, action: push
```

`docker login docker-registry.it.csiro.au`

```text
Username: xxx123
Password: 
WARNING! Your password will be stored unencrypted in /home/xxx123/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store
```

## Appendix

To check what is available in terms of packages in the ubuntu distro (thankfully seems consistend with Debian):

```sh
docker run -it ubuntu:22.04 /bin/bash
```

To check all conda-forge packages

```sh
mamba search -c conda-forge >> conda-forge.txt
```
