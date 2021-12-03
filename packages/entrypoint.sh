#!/bin/bash
SWIFT_PAT=$1

set -e  # Exit immediately if a command exits with a non-zero status.

SRC_ROOT=/src
CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}

mkdir -p ${CSIRO_BITBUCKET} \
  && cd ${CSIRO_BITBUCKET} \
  && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/numerical-sl-cpp.git \
  && cd numerical-sl-cpp \
  && git checkout testing \
  && cd .. \
  && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/datatypes.git \
  && cd datatypes \
  && git checkout testing \
  && cd .. \
  && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/swift.git \
  && cd swift \
  && git checkout research \
  && cd ..


# Change the ownership of the newly produced files
cd /pkgs
touch test.txt
chown -R ${CURRENT_UID} *
