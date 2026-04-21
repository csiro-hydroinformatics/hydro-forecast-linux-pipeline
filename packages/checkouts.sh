#!/bin/bash
SWIFT_PAT=${SWIFT_PAT_ENV_VAR}
# TEST_PAT=${TEST_PAT_ENV_VAR}
BRANCH_NAME=${BRANCH_NAME_ENV_VAR}
# BRANCH_NAME="testing"

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
sudo ls

umask 022 

# git lfs install

. globals

SRC_ROOT=${HOME}/src
GHE_REPOS=${SRC_ROOT}
# GITHUB_REPOS is kept as an alias for compatibility with any downstream references
GITHUB_REPOS=${SRC_ROOT}

ROOT_BUILD_DIR=${HOME}/build
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

mkdir -p ${GHE_REPOS} \
  && cd ${GHE_REPOS} \
  && echo cloning https://SOMETHING@github.com/csiro-internal/sf-stack.git \
  && git clone https://${SWIFT_PAT}@github.com/csiro-internal/sf-stack.git \
  && cd sf-stack \
  && git checkout ${BRANCH_NAME} || ret_code=1;

_exit_if_failed $ret_code "Failed to checkout sf-stack"

. ${GHE_REPOS}/sf-stack/reponames.sh
. ${GHE_REPOS}/sf-stack/hashsums

echo Testing whether reposha has the expected SHA for c-c: ${reposha["cruise-control"]}

# turn the detached message off
git config --global advice.detachedHead false

mkdir -p ${GHE_REPOS} \
  && cd ${GHE_REPOS} \
  && git clone https://${SWIFT_PAT}@github.com/csiro-internal/cruise-control.git \
  && cd cruise-control \
  && git checkout ${reposha["cruise-control"]} || ret_code=1;

_exit_if_failed $ret_code "Failed to checkout cruise-control"

# R package dep installs moved to base image ../images

ret_code=0

for f in ${reponames_bb_checkout[@]} ; do
  ret_code=0;
  cd ${GHE_REPOS} \
    && git clone https://${SWIFT_PAT}@github.com/csiro-internal/${f}.git \
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

# This script is run by AZDO under the user `vsts_azpcontainer`
# It seems however to be configured such that it can sudo without password
# I came across the following issue, which seems relevent, though am not across it fully, far from it.
# Anyway, `sudo make install` seems to work which is all I care
# https://github.com/microsoft/azure-pipelines-agent/issues/2043

cd ${GITHUB_REPOS}/config-utils \
  && sudo make install \
  || ret_code=1;


_exit_if_failed $ret_code "Failed to install config-utils"

# _exit_if_failed 244 "Failing on purpose to incrementally build the reengineered pipeline"