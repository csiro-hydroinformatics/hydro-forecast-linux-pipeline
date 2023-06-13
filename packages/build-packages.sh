#!/bin/bash

# I think setting `set -e` makes this return with a zero status, even if, say, `docker run` returns a nonzero status.
# set -e

SWIFT_PAT=${SWIFT_PAT_ENV_VAR}
# TEST_PAT=${TEST_PAT_ENV_VAR}
BRANCH_NAME=${BRANCH_NAME_ENV_VAR}

# bitbucket personal access tokens can have forward slashes. 
# And tend to. This considerably messes things up. 
# This is a fallback in case there are "/" in the PAT to replace it with a URL compatible string:
SWIFT_PAT="${SWIFT_PAT//\//%2F}"

OUT_ARTIFACT_PATH=$1  # $(Build.SourcesDirectory)/artifacts

# echo from within build-packages.sh: TEST_PAT=${TEST_PAT} LOCAL_TEST_PAT_ENV_VAR=${LOCAL_TEST_PAT_ENV_VAR}

export IMAGE_NAME=swift_builder
export CURRENT_UID=$(id -u):$(id -g)

# export ARTIFACT_PATH=$(pwd)/pkgs
# mkdir -p ${ARTIFACT_PATH}

echo CURRENT_UID=${CURRENT_UID}
# echo SRC_PATH=${SRC_PATH}

# docker build --no-cache --force-rm --build-arg CURRENT_UID_ARG=${CURRENT_UID} -t ${IMAGE_NAME} .
docker build --build-arg CURRENT_UID_ARG=${CURRENT_UID} -t ${IMAGE_NAME} .
docker run --rm --name ${IMAGE_NAME} -v "${OUT_ARTIFACT_PATH}:/pkgs/" ${IMAGE_NAME} ${SWIFT_PAT} ${BRANCH_NAME} 
ret_code=$?
if [ $ret_code != 0 ]; then 
    echo ERROR: Docker image run returned with a nonzero status code.
    exit $ret_code; 
fi

echo build-packages.sh: OUT_ARTIFACT_PATH = ${OUT_ARTIFACT_PATH} contains:
ls ${OUT_ARTIFACT_PATH}

## Obsolete?
# docker rm -f ${IMAGE_NAME}
# docker run --rm --name ${IMAGE_NAME} ${IMAGE_NAME}
