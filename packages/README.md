# Docker image for HYDROFC CI

## Build the base ubuntu image

See [../images/README.md](../images/README.md)

## Run the CI docker file

```sh
TARGET=ubuntu-jammy-202310
DOCKER_REPOSITORY=hydrofc
IMAGE_NAME=ubuntu-jammy-202310
TAG="20231025"
EXTRA_ARGS=""

# to clean up:
# docker rmi --force ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG}

# can use --no-cache:
# EXTRA_ARGS="--no-cache"
cd ${HOME}/src/hydro-fc-packaging/packages

BUILD_TAG=`date --iso-8601`

root_out_dir=${HOME}/tmp/hfc_ci
mkdir -p $root_out_dir
. ${HOME}/credentials/secrets/az_pat 
export BRANCH_NAME_ENV_VAR=testing

./build-packages.sh ${root_out_dir}  2>&1 | tee build-ci-${BUILD_TAG}.log
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
