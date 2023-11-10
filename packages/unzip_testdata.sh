#!/bin/bash

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
