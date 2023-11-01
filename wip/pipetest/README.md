

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
```