#!/bin/bash
SWIFT_PAT=${SWIFT_PAT_ENV_VAR}
# TEST_PAT=${TEST_PAT_ENV_VAR}
BRANCH_NAME=${BRANCH_NAME_ENV_VAR}

# bitbucket personal access tokens can have forward slashes. 
# And tend to. This considerably messes things up. 
# This is a fallback in case there are "/" in the PAT to replace it with a URL compatible string:
# echo SWIFT_PAT=${SWIFT_PAT}
SWIFT_PAT="${SWIFT_PAT//\//%2F}"
# echo from entrypoint.sh
# echo SWIFT_PAT=${SWIFT_PAT}


# echo TEST_PAT=$TEST_PAT
# echo TEST_PAT_ENV_VAR=$TEST_PAT_ENV_VAR

# set -e  # Exit immediately if a command exits with a non-zero status.

echo whoami
whoami
echo HOME:
echo $HOME


SRC_ROOT=${HOME}/src
CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}

ROOT_BUILD_DIR=/tmp/build
DEB_PKGS_DIR=${ROOT_BUILD_DIR}/deb_pkgs
mkdir -p ${DEB_PKGS_DIR}
PY_PKGS_DIR=${ROOT_BUILD_DIR}/py_pkgs
mkdir -p ${PY_PKGS_DIR}
R_PKGS_DIR=${ROOT_BUILD_DIR}/r_pkgs
mkdir -p ${R_PKGS_DIR}

. bash_functions
_exit=0 # exit process if failed: 0 is false, anything else yes
_NOT_FOUND_RC=127

ret_code=0

# used to test WIRADA-669
# blah_test_fail || ret_code=127

# if [ $ret_code != 0 ]; then 
#     echo ERROR: Testing whether the build task fails as early as expected.
#     exit $ret_code; 
# fi

mkdir -p ${CSIRO_BITBUCKET} \
  && cd ${CSIRO_BITBUCKET} \
  && echo cloning https://SOMETHING@bitbucket.csiro.au/scm/sf/sf-stack.git \
  && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/sf-stack.git \
  && cd sf-stack \
  && git checkout ${BRANCH_NAME} || ret_code=1;

_exit_if_failed $ret_code "Failed to checkout sf-stack"

source ${CSIRO_BITBUCKET}/sf-stack/reponames.sh
source ${CSIRO_BITBUCKET}/sf-stack/hashsums

echo Testing whether reposha has the expected SHA for c-c: ${reposha["cruise-control"]}

# turn the detached message off
git config --global advice.detachedHead false

mkdir -p ${CSIRO_BITBUCKET} \
  && cd ${CSIRO_BITBUCKET} \
  && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/cruise-control.git \
  && cd cruise-control \
  && git checkout ${reposha["cruise-control"]} || ret_code=1;

_exit_if_failed $ret_code "Failed to checkout cruise-control"

# R package dep installs moved to base image ../images

ret_code=0

for f in ${reponames_bb_checkout[@]} ; do
  ret_code=0;
  cd ${CSIRO_BITBUCKET} \
    && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/${f}.git \
    && cd $f \
    && git checkout ${reposha["$f"]} || ret_code=1;

  _exit_if_failed $ret_code "Failed to clone repository ${f}"
done

# Clone github repos

ret_code=0

for f in ${reponames_gh[@]} ; do
  ret_code=0;
  cd ${GITHUB_REPOS} \
    && git clone https://github.com/csiro-hydroinformatics/${f}.git \
    && cd $f \
    && git checkout ${reposha["$f"]} || ret_code=1;

  _exit_if_failed $ret_code "Failed to clone repository ${f}"
done

TEST_DATA_DIR=${HOME}/tmp/data
# NOTE: moved test data download to base image
# mkdir -p ${TEST_DATA_DIR}
export SWIFT_SAMPLE_DATA_DIR=${TEST_DATA_DIR}/documentation

cd ${GITHUB_REPOS}/config-utils \
  && make install \
  || ret_code=1;


_exit_if_failed $ret_code "Failed to install config-utils"

_exit_if_failed 244 "Failing on purpose to test new pipeline"