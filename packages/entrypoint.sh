#!/bin/bash
SWIFT_PAT=$1
TEST_PAT=$2

echo from entrypoint.sh
echo TEST_PAT=$TEST_PAT
echo TEST_PAT_ENV_VAR=$TEST_PAT_ENV_VAR

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
  && git checkout experimental \
  && cd ..

# Clone github repos

mkdir -p ${GITHUB_REPOS} \
  && cd ${GITHUB_REPOS} \
  && git clone https://github.com/csiro-hydroinformatics/moirai.git \
  && cd moirai \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/rcpp-interop-commons.git \
  && cd rcpp-interop-commons \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/threadpool.git \
  && cd threadpool \
  && git checkout master \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/config-utils.git \
  && cd config-utils \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/wila.git \
  && cd wila \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/efts.git \
  && cd efts \
  && git checkout master \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/mhplot.git \
  && cd mhplot \
  && git checkout master \
  && cd ..

cd ${GITHUB_REPOS}/config-utils \
  && make install

DEB_PKGS_DIR=/tmp/debpkgs
mkdir -p ${DEB_PKGS_DIR}

export DEBUG_DEB=0

DEST_ROOT=/tmp/debbuild

cd /internal \
  && chmod +x ./build_debian_pkgs.sh \
  && ./build_debian_pkgs.sh ${DEB_PKGS_DIR} ${SRC_ROOT} ${DEST_ROOT}

if [ $? == 0 ]; then
    echo "OK: build_debian_pkgs.sh completed with no error";
else
    echo "FAILED: build_debian_pkgs.sh";
    return 1;
fi

# Change the ownership of the newly produced files
cp ${DEB_PKGS_DIR}/* /pkgs/
cd /pkgs/
touch test.txt
chown -R ${CURRENT_UID} *
