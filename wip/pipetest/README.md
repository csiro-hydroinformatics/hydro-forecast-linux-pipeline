
# Testing the pipeline using a custom image

This readme has instructions to reproduce running some of the steps for the build pipeline on a local desktop, to speed up iterative development.

```sh
TAG="20231025"
TAG=20231110
docker pull docker-registry.it.csiro.au/hydrofc/ubuntu-jammy-202310:${TAG}
docker tag docker-registry.it.csiro.au/hydrofc/ubuntu-jammy-202310:${TAG} hydrofc/ubuntu-jammy-202310:${TAG}
```

```sh
TARGET=fs-pipeline-202310
DOCKER_REPOSITORY=hydrofc
IMAGE_NAME=$TARGET
TAG=`date +%Y%m%d`
EXTRA_ARGS=""

# to clean up:
# docker rmi --force ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG}

# can use --no-cache:
# EXTRA_ARGS="--no-cache"
cd ${HOME}/src/hydro-fc-packaging/wip/pipetest
. ~/credentials/secrets/swift_pats 

docker build  \
  -f Dockerfile-pipeline \
  --target ${TARGET}  \
  --build-arg SWIFT_PAT_ARG="${SWIFT_PAT_ENV_VAR}" \
  --tag ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG} ${EXTRA_ARGS}  \
  --progress=plain . 2>&1 | tee build-${IMAGE_NAME}.log

# OR
docker build  \
  -f Dockerfile-pipeline \
  --no-cache \
  --target ${TARGET}  \
  --build-arg SWIFT_PAT_ARG="${SWIFT_PAT_ENV_VAR}" \
  --tag ${DOCKER_REPOSITORY}/${IMAGE_NAME}:${TAG} ${EXTRA_ARGS}  \
  --progress=plain . 2>&1 | tee build-${IMAGE_NAME}.log
```