#!/bin/bash

SRC_ROOT=$1
CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}

# https://mariadb.com/kb/en/operating-system-error-codes/
_ENOENT=2

umask 022

. bash_functions
. globals

echo entering ${ROOT_DATA_DIR}
cd ${ROOT_DATA_DIR}
ret_code=$?
_exit_if_failed $ret_code "Failed to change dir to ${ROOT_DATA_DIR}"

# Jul 24: deprecate as makes it more difficult than useful for others to adapt the pipeline
# # sf-test-data.git
# ls sf-test-data/
# ret_code=$?
# _exit_if_failed $ret_code "Failed: sf-test-data not found under ${ROOT_DATA_DIR}"
mkdir -p ${ROOT_DATA_DIR}/swift
mkdir -p ${ROOT_DATA_DIR}/chypp
# mv sf-test-data/swift_test_data.7z swift/
# mv sf-test-data/chypp_test_data.7z chypp/

curl -o ${ROOT_DATA_DIR}/chypp/chypp_test_data.7z ftp://ftp.csiro.au/hfc/chypp_test_data.7z
ret_code=$?
_exit_if_failed $ret_code "chypp_test_data.7z download failed"

curl -o ${ROOT_DATA_DIR}/swift/swift_test_data.7z ftp://ftp.csiro.au/hfc/swift_test_data.7z
ret_code=$?
_exit_if_failed $ret_code "swift_test_data.7z download failed"

# First, let us check we have the sample data file installed. Otherwise no point.
# The data is present on the base image we use for the pipeline, not checked out live by the pipeline to save runtime.
if [ ! -e ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs/swift/data/ ]; then
    echo ERROR: ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs/swift/data/ not found
    exit ${_ENOENT}; 
fi

# if [ ! -e ${ROOT_DATA_DIR}/sf-test-data/swift_sample_data.rda ]; then
#     echo ERROR: 'swift_sample_data.rda' not found, expected ${ROOT_DATA_DIR}/sf-test-data/swift_sample_data.rda 
#     exit ${_ENOENT}; 
# fi
curl -o ${ROOT_DATA_DIR}/swift/swift_sample_data.rda ftp://ftp.csiro.au/hfc/swift_sample_data.rda
ret_code=$?
_exit_if_failed $ret_code "swift_sample_data.rda download failed"

mv ${ROOT_DATA_DIR}/swift/swift_sample_data.rda ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs/swift/data/

cd ${ROOT_DATA_DIR}/swift/
7z x swift_test_data.7z 
chmod -R go+rx *

cd ${ROOT_DATA_DIR}/chypp/
7z x chypp_test_data.7z 
chmod -R go+rx *

if [ ! -e ${CHYPP_TEST_DIR} ]
then
  echo ERROR CHyPP test data directory not found ${CHYPP_TEST_DIR}
fi
