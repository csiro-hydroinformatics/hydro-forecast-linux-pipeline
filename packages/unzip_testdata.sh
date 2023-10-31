#!/bin/bash

. globals
umask 022

cd ${ROOT_DATA_DIR}
# sf-test-data.git
ls sf-test-data/
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
