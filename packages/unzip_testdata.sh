#!/bin/bash

SRC_ROOT=$1
CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}

umask 022

. bash_functions
. globals

echo entering ${ROOT_DATA_DIR}
cd ${ROOT_DATA_DIR}
ret_code=$?
_exit_if_failed $ret_code "Failed to change dir to ${ROOT_DATA_DIR}"

# sf-test-data.git
ls sf-test-data/
ret_code=$?
_exit_if_failed $ret_code "Failed: sf-test-data not found under ${ROOT_DATA_DIR}"
mkdir -p ${ROOT_DATA_DIR}/swift
mkdir -p ${ROOT_DATA_DIR}/chypp
mv sf-test-data/swift_test_data.7z swift/
mv sf-test-data/chypp_test_data.7z chypp/
mv sf-test-data/swift_sample_data.rda ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs/swift/data/

cd ${ROOT_DATA_DIR}/swift/
7z x swift_test_data.7z 
chmod -R go+rx *

cd ${ROOT_DATA_DIR}/chypp/
7z x chypp_test_data.7z 
chmod -R go+rx *

# First, let us check we have the sample data file installed. Otherwise no point.
cd ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs/swift/data/

if [ ! -e swift_sample_data.rda ]; then
    # curl -o swift_sample_data.rda https://cloudstor.aarnet.edu.au/plus/s/vfIbwcISy8jKQmg/download
    if [ ! -e ${GITHUB_REPOS}/sf-test-data/swift_sample_data.rda ]; then
        echo ERROR: 'swift_sample_data.rda' not found, and not found either in ${GITHUB_REPOS}/sf-test-data/swift_sample_data.rda 
        exit ${_ENOENT}; 
    fi
    cp ${GITHUB_REPOS}/sf-test-data/swift_sample_data.rda ./
fi

if [ ! -e ${CHYPP_TEST_DIR} ]
then
  echo ERROR CHyPP test data directory not found ${CHYPP_TEST_DIR}
fi
