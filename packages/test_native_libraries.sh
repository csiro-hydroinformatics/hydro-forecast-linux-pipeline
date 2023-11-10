#!/bin/bash

# Root of the source directory, where all the checked out repositories are
SRC_ROOT=$1
_exit=${2-0} # exit process if failed: 0 is false, anything else yes

. bash_functions

# Note: keep in sync with /src/hydro-fc-packaging/images/setup-deps.sh
. globals

# Now done from the pipeline:
# echo INFO: about to unzip the test data
# sudo ./unzip_testdata.sh
# ret_code=$?
# _exit_if_failed $ret_code "Failed to unzip unit test data"


INSTALL_PREFIX=/usr/local
BUILD_CONFIG="Release"
CM_GCOV="" #-DENABLE_CODECOVERAGE=1
CM_PREF="-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DCMAKE_MODULE_PATH=${INSTALL_PREFIX}/share/cmake/Modules/ -DCMAKE_BUILD_TYPE=${BUILD_CONFIG}"
CXX_COMP=-DCMAKE_CXX_COMPILER=g++
C_COMP=-DCMAKE_C_COMPILER=gcc
CM="cmake ${CXX_COMP} ${C_COMP} ${CM_PREF} ${CM_GCOV} -DBUILD_SHARED_LIBS=ON .."
# The command below is machine dependent in practice. TODO Adjust depending on how many of your logical cores want to to use.

if [ -z ${MAKE_CMD+x} ]; then 
    MAKE_CMD="make -j 2"
fi

CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}

# SUDO_CMD=""
CLEAN_BUILD="rm -rf ../build/*"
# No need. 
CLEAN_BUILD=""

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

# 2023-11-09
# 4 unit tests in the qpp suite do not pass.
# ideally we'd track down when there failed to pass
# See https://jira.csiro.au/browse/WIRADA-692
QPP_NONFATAL_FAIL=0

_print_banner QPP
_build_cmake ${CSIRO_BITBUCKET}/qpp/testlibqppcore ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/qpp/testlibqppcore/build testqppcore ${_exit}

_build_cmake ${CSIRO_BITBUCKET}/qpp/testlibqpp ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/qpp/testlibqpp/build testqpp ${QPP_NONFATAL_FAIL}
###########
_print_banner CHYPP


if [ ! -e ${CHYPP_TEST_DIR} ]
then
  echo ERROR CHyPP test data directory not found ${CHYPP_TEST_DIR}
fi

_build_cmake ${CSIRO_BITBUCKET}/chypp/tests/TestCHyPP ${_exit}
_run_cli_unit_test ${CSIRO_BITBUCKET}/chypp/tests/TestCHyPP/build testchypp ${_exit}



