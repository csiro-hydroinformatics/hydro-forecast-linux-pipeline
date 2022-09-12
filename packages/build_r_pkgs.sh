#!/bin/bash

ROOT_OUT_DIR=$1
SRC_ROOT=$2

#####  
## TESTS
# ROOT_OUT_DIR=$HOME/tmp/test_artifacts/
# SRC_ROOT=$HOME/src
# ROOT_OUT_DIR=${HOME}/tmp/debs
# SRC_ROOT=${HOME}/src

set -e  # Exit immediately if a command exits with a non-zero status.

CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}


DEBUG_R=0

mkdir -p ${ROOT_OUT_DIR}

# # Make sure there is a user Renviron to avoid risks of read-only clash (although theoretical with Docker/jovyan) 
# if [ ! -e $HOME/.Renviron ]; then
#     mkdir -p ${HOME}/R/local
#     echo "R_LIBS=${HOME}/R/local" > $HOME/.Renviron 
# fi

# cd ${ROOT_OUT_DIR}
# if [ ! -e ${SRC_ROOT}/cruise-control/scripts/setup_dependent_packages.r ]; then
#     echo "Not found: ${SRC_ROOT}/cruise-control/scripts/setup_dependent_packages.r"
#     exit 1;
# fi

# Rscript ${SRC_ROOT}/cruise-control/scripts/setup_dependent_packages.r
# ret_code=$?
# if [ $ret_code != 0 ]; then 
#     echo ERROR: Installations of dependencies with setup_dependent_packages.r appears to have FAILED.
#     exit $ret_code; 
# fi

# NOTE: installs a lot.
# also installing the dependencies 'cpp11’, 'lifecycle’, 'rlang’, 'tidyselect’, 'vctrs’, 'pillar’, 'cli’, 'vroom’, 'tzdb’, 'viridisLite’, 'gridExtra’, 'dplyr’, 'downloader’, 'glue’, 'htmltools’, 'igraph’, 'influenceR’, 'readr’, 'tibble’, 'viridis’, 'visNetwork’


SUDOCMD=
#SUDOCMD=sudo

R_REPO_DIR=${ROOT_OUT_DIR}/lib/R_repo
R_SRC_REPO_PATH=${R_REPO_DIR}/src/contrib
mkdir -p $R_SRC_REPO_PATH

RCMD_BUILD_OPT=

R_EXE=R
R_VANILLA="${R_EXE} --no-save --no-restore-data"


_clean_possible_tarballs () {
    if test -n "$(find . -maxdepth 1 -name '*.tar.gz' -print -quit)"
    then
        rm *.tar.gz
    fi
}


cd ${GITHUB_REPOS}/c-interop/bindings/R/pkgs
${R_VANILLA} -e "library(roxygen2) ; roxygenize('cinterop')"
${R_VANILLA} -e "devtools::test(pkg='${GITHUB_REPOS}/c-interop/bindings/R/pkgs/cinterop')"
_clean_possible_tarballs
${R_VANILLA} CMD build cinterop
if [ $? != 0 ]; then 
    echo ERROR: R package build cinterop failed
    exit $?; 
fi

# May need, if building vignettes in uchronia and co
# ${R_VANILLA} CMD INSTALL cinterop_
cp cinterop_*.tar.gz ${R_SRC_REPO_PATH}/
${R_VANILLA} CMD INSTALL cinterop_*.tar.gz
cd ${GITHUB_REPOS}/config-utils/R/packages
${R_VANILLA} -e "roxygen2::roxygenize('msvs')"
# ${R_VANILLA} -e "devtools::test(pkg='${GITHUB_REPOS}/config-utils/R/packages/msvs')"
_clean_possible_tarballs
${R_VANILLA} CMD build msvs
if [ $? != 0 ]; then 
    echo ERROR: R package build msvs failed
    exit $?; 
fi
${R_VANILLA} CMD INSTALL msvs_*.tar.gz
cp msvs_*.tar.gz ${R_SRC_REPO_PATH}/

# TEST_DATA_DIR=${ROOT_OUT_DIR}/tmp/data
TEST_DATA_DIR=${HOME}/tmp/data
mkdir -p ${TEST_DATA_DIR}

cd ${TEST_DATA_DIR}
if [ ! -e swift_test_data.7z ]; then
    curl -o swift_test_data.7z https://cloudstor.aarnet.edu.au/plus/s/RU6kLfzuncINu4f/download
    7z x -y swift_test_data.7z 
fi

export SWIFT_SAMPLE_DATA_DIR=${TEST_DATA_DIR}/documentation

cd ${CSIRO_BITBUCKET}/datatypes/bindings/R/pkgs
_clean_possible_tarballs
${R_VANILLA} CMD build ${RCMD_BUILD_OPT} uchronia
if [ $? != 0 ]; then 
    echo ERROR: R package uchronia cinterop failed
    exit $?; 
fi
${R_VANILLA} CMD INSTALL uchronia_*.tar.gz
cp uchronia_*.tar.gz ${R_SRC_REPO_PATH}/

cd ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs/swift/data/

if [ ! -e swift_sample_data.rda ]; then
    curl -o swift_sample_data.rda https://cloudstor.aarnet.edu.au/plus/s/vfIbwcISy8jKQmg/download
fi

cd ${GITHUB_REPOS}/
# git clone git@github.com:csiro-hydroinformatics/mhplot.git
rm mhplot_*.tar.gz
${R_VANILLA} -e "roxygen2::roxygenize('mhplot')"
${R_VANILLA} CMD build ${RCMD_BUILD_OPT} mhplot
${R_VANILLA} CMD INSTALL mhplot_*.tar.gz
cp mhplot_*.tar.gz ${R_SRC_REPO_PATH}/

cd ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs
_clean_possible_tarballs
${R_VANILLA} -e "roxygen2::roxygenize('joki')"
${R_VANILLA} CMD build ${RCMD_BUILD_OPT} joki
${R_VANILLA} CMD INSTALL joki_*.tar.gz
cp joki_*.tar.gz ${R_SRC_REPO_PATH}/

cd ${CSIRO_BITBUCKET}/swift/bindings/R/pkgs

Rscript -e "required <- c('calibragem') ; already <- installed.packages()[,1] ; missingPkgs <- required[ !(required %in% already)] ; if(length(missingPkgs) > 0) {  quit(save = 'no', status = 1, runLast = TRUE) }"

if [ $? != 0 ]; then
  # echo "INFO building 'calibragem' first before swift vignettes"; 
  ${R_VANILLA} CMD build --no-build-vignettes swift
  if [ $? != 0 ]; then 
      echo ERROR: R package build swift failed
      exit $?; 
  fi

  ${R_VANILLA} CMD INSTALL swift_*.tar.gz
  ${R_VANILLA} CMD build ${RCMD_BUILD_OPT} calibragem
  ${R_VANILLA} CMD INSTALL calibragem_*.tar.gz
  cp calibragem_*.tar.gz ${R_SRC_REPO_PATH}/
fi

########################

${R_VANILLA} CMD build ${RCMD_BUILD_OPT} swift
if [ $? != 0 ]; then 
    echo ERROR: R package build swift failed
    exit $?; 
fi
${R_VANILLA} CMD INSTALL swift_*.tar.gz
cp swift_*.tar.gz ${R_SRC_REPO_PATH}/

cd ${GITHUB_REPOS}/
rm efts*.tar.gz
${R_VANILLA} -e "devtools::test(pkg='${GITHUB_REPOS}/efts')"
${R_VANILLA} CMD build ${RCMD_BUILD_OPT} efts
if [ $? != 0 ]; then 
    echo ERROR: R package build efts failed
    exit $?; 
fi
cp efts_*.tar.gz ${R_SRC_REPO_PATH}/


cd ${CSIRO_BITBUCKET}/qpp/bindings/R/pkgs
${R_VANILLA} CMD build ${RCMD_BUILD_OPT} qpp
${R_VANILLA} CMD INSTALL qpp_*.tar.gz
cp qpp_*.tar.gz ${R_SRC_REPO_PATH}/


Rscript -e "library(tools) ; write_PACKAGES(dir='${R_SRC_REPO_PATH}/', type='source')"
