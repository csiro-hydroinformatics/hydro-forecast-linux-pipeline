#!/bin/bash

# Root of the source directory, where all the checked out repositories are
SRC_ROOT=$1
_exit=${2-0} # exit process if failed: 0 is false, anything else yes

. bash_functions

# Note: keep in sync with /src/hydro-fc-packaging/images/setup-deps.sh
ROOT_DATA_DIR=/usr/local/share/data
TEST_DATA_DIR=${ROOT_DATA_DIR}/swift
cd ${TEST_DATA_DIR}
if [ ! -e swift_test_data.7z ]; then
    sudo curl -o swift_test_data.7z https://cloudstor.aarnet.edu.au/plus/s/RU6kLfzuncINu4f/download
fi
sudo echo CHECK default root umask:
sudo umask
sudo 7z x -y swift_test_data.7z 
sudo chmod -R go+rx ./* 

export SWIFT_SAMPLE_DATA_DIR=${TEST_DATA_DIR}/documentation
export SWIFT_TEST_DIR=${TEST_DATA_DIR}/documentation

INSTALL_PREFIX=/usr/local
BUILD_CONFIG="Release"
CM_GCOV="" #-DENABLE_CODECOVERAGE=1
CM_PREF="-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${INSTALL_PREFIX}/share/cmake/Modules/ -DCMAKE_BUILD_TYPE=${BUILD_CONFIG}"
CXX_COMP=-DCMAKE_CXX_COMPILER=g++
C_COMP=-DCMAKE_C_COMPILER=gcc
CM="cmake ${CXX_COMP} ${C_COMP} ${CM_PREF} ${CM_GCOV} -DBUILD_SHARED_LIBS=ON .."
# The command below is machine dependent in practice. TODO Adjust depending on how many of your logical cores want to to use.
MAKE_CMD="make -j 2"

CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}

# SUDO_CMD=""
CLEAN_BUILD="rm -rf ../build/*"

CLEAN_BUILD=""

_build_cmake () {
    src_dir=$1
    _eif=${2-0}
    ret_code=0
    if [ ! -e ${src_dir} ]; then
        echo "FAILED: directory not found: ${src_dir}";
        ret_code=127;
    else
        cd ${src_dir} && \
        mkdir -p ${src_dir}/build \
        && cd ${src_dir}/build \
        && ${CLEAN_BUILD} \
        && ${CM} \
        && ${MAKE_CMD} \
        || ret_code=1;

        if [ $ret_code == 0 ]; then
            echo "OK: built $src_dir";
        else
            echo "FAILED building: $src_dir";
        fi
    fi
    if [ $_eif != 0 ]; then
        _exit_if_failed $ret_code "compilation of ${src_dir}"
    fi
    return $ret_code
}

_run_cli_unit_test () {
    build_dir=$1
    exe_name=$2
    _eif=${3-0} # exit if failed
    _rc=0
    if [ ! -e ${build_dir} ]; then
        echo "FAILED: directory not found: ${build_dir}";
        _rc=127;
    else
        cd ${build_dir};
        if [ ! -e ${exe_name} ]; then
            echo "FAILED: file ${exe_name} not found in ${build_dir}";
            _rc=127;
        else
            ./${exe_name}
            ret_code=$?
            if [ $ret_code != 0 ]; then 
                echo FAILED: unit test ${exe_name} return code is not 0 but $ret_code
                _rc=$ret_code;
            fi
        fi
    fi
    if [ $_eif != 0 ]; then
        _exit_if_failed $_rc "unit tests ${exe_name}"
    fi
    return $_rc
}

_print_banner() {
    echo
    echo "==============================================="
    echo $1
    echo "==============================================="
    echo
}



_print_banner MOIRAI
_build_cmake ${GITHUB_REPOS}/moirai ${_exit}

_run_cli_unit_test ${GITHUB_REPOS}/moirai/build moirai_test ${_exit}
_run_cli_unit_test ${GITHUB_REPOS}/moirai/build moirai_test_api ${_exit}
###########
_print_banner WILA
_build_cmake ${GITHUB_REPOS}/wila ${_exit}

_run_cli_unit_test ${GITHUB_REPOS}/wila/build wila_tests ${_exit}
###########
_print_banner Numerical libraries
_build_cmake ${GITHUB_REPOS}/numerical-sl-cpp ${_exit}

_run_cli_unit_test ${GITHUB_REPOS}/numerical-sl-cpp/build sfsl_tests ${_exit}
###########
_print_banner UCHRONIA
_build_cmake ${CSIRO_BITBUCKET}/datatypes/tests ${_exit}

_run_cli_unit_test ${CSIRO_BITBUCKET}/datatypes/tests/build datatypes_tests ${_exit}

_build_cmake ${CSIRO_BITBUCKET}/datatypes/tests/api ${_exit}

_run_cli_unit_test ${CSIRO_BITBUCKET}/datatypes/tests/api/build datatypes_tests_api ${_exit}
###########

# two cores on the MS hosted AZdevops build agents SFAIK
export SWIFT_UT_MAX_THREAD_LEVELS=2 

_print_banner SWIFT
_build_cmake ${CSIRO_BITBUCKET}/swift/tests/testlibswift ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/swift/tests/testlibswift/build testswift ${_exit}

_build_cmake ${CSIRO_BITBUCKET}/swift/tests/api ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/swift/tests/api/build testswiftapi ${_exit}

_build_cmake ${CSIRO_BITBUCKET}/swift/tests/calib ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/swift/tests/calib/build testswiftcalib ${_exit}

###########
_print_banner QPP
_build_cmake ${CSIRO_BITBUCKET}/qpp/testlibqppcore ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/qpp/testlibqppcore/build testqppcore ${_exit}

_build_cmake ${CSIRO_BITBUCKET}/qpp/testlibqpp ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/qpp/testlibqpp/build testqpp ${_exit}
###########
_print_banner CHYPP

export CHYPP_TEST_DIR=${HOME}/data/chypp/TestData
_build_cmake ${CSIRO_BITBUCKET}/chypp/tests/TestCHyPP ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/chypp/tests/TestCHyPP/build testchypp ${_exit}



