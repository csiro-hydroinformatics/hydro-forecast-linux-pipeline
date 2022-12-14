#!/bin/bash
# set -e

SWIFT_PAT=${SWIFT_PAT_ENV_VAR}
TEST_PAT=${TEST_PAT_ENV_VAR}

OUT_ARTIFACT_PATH=$1  # $(Build.SourcesDirectory)/artifacts

echo from within build-packages.sh: TEST_PAT=${TEST_PAT} LOCAL_TEST_PAT_ENV_VAR=${LOCAL_TEST_PAT_ENV_VAR}

export IMAGE_NAME=swift_builder
export CURRENT_UID=$(id -u):$(id -g)

# export ARTIFACT_PATH=$(pwd)/pkgs
# mkdir -p ${ARTIFACT_PATH}

echo CURRENT_UID=${CURRENT_UID}
# echo SRC_PATH=${SRC_PATH}

# docker build --no-cache --force-rm --build-arg CURRENT_UID_ARG=${CURRENT_UID} -t ${IMAGE_NAME} .
docker build --build-arg CURRENT_UID_ARG=${CURRENT_UID} -t ${IMAGE_NAME} .
docker run --rm --name ${IMAGE_NAME} -v "${OUT_ARTIFACT_PATH}:/pkgs/" ${IMAGE_NAME} ${SWIFT_PAT} ${TEST_PAT} 

echo build-packages.sh: OUT_ARTIFACT_PATH = ${OUT_ARTIFACT_PATH} contains:
ls ${OUT_ARTIFACT_PATH}

## Obsolete?
# docker rm -f ${IMAGE_NAME}
# docker run --rm --name ${IMAGE_NAME} ${IMAGE_NAME}
