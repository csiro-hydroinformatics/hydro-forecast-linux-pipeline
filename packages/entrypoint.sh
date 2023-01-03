#!/bin/bash
SWIFT_PAT=$1
BRANCH_NAME=$2

echo from entrypoint.sh
# echo TEST_PAT=$TEST_PAT
# echo TEST_PAT_ENV_VAR=$TEST_PAT_ENV_VAR

# set -e  # Exit immediately if a command exits with a non-zero status.


SRC_ROOT=/src
CSIRO_BITBUCKET=${SRC_ROOT}
GITHUB_REPOS=${SRC_ROOT}

ROOT_BUILD_DIR=/tmp/build
DEB_PKGS_DIR=${ROOT_BUILD_DIR}/deb_pkgs
mkdir -p ${DEB_PKGS_DIR}
PY_PKGS_DIR=${ROOT_BUILD_DIR}/py_pkgs
mkdir -p ${PY_PKGS_DIR}
R_PKGS_DIR=${ROOT_BUILD_DIR}/r_pkgs
mkdir -p ${R_PKGS_DIR}

ret_code=0

mkdir -p ${CSIRO_BITBUCKET} \
  && cd ${CSIRO_BITBUCKET} \
  && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/sf-stack.git \
  && cd sf-stack \
  && git checkout ${BRANCH_NAME} || ret_code=1;

if [ $ret_code != 0 ]; then 
    echo ERROR: Failed to checkout sf-stack
    exit $ret_code; 
fi

source ${CSIRO_BITBUCKET}/sf-stack/reponames.sh
source ${CSIRO_BITBUCKET}/sf-stack/hashsums

mkdir -p ${CSIRO_BITBUCKET} \
  && cd ${CSIRO_BITBUCKET} \
  && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/cruise-control.git \
  && cd cruise-control \
  && git checkout reposha["cruise-control"] || ret_code=1;

if [ $ret_code != 0 ]; then 
    echo ERROR: Failed to checkout cruise-control
    exit $ret_code; 
fi

# Install R dependencies early: something became amiss recently, perhaps with cran.csiro.au
# Make sure there is a user Renviron to avoid risks of read-only clash (although theoretical with Docker/jovyan) 
if [ ! -e $HOME/.Renviron ]; then
    mkdir -p ${HOME}/R/local
    echo "R_LIBS=${HOME}/R/local" > $HOME/.Renviron 
fi

# Encountered issues when installing on top of R 4.0.4 from Debian Bullseye, starting Sept 2022, if using cran.csiro.au, and probably any other
# Something appears to have changed in the dependencies of a CRAN package, perhaps DiagrammeR or dependency. 
# Instead, using the snapshot kindly provided by Microsoft...

export CRAN_REPOS="https://cran.microsoft.com/snapshot/2021-02-15"

cd ${R_PKGS_DIR}
if [ ! -e ${SRC_ROOT}/cruise-control/scripts/setup_dependent_packages.r ]; then
    echo "Not found: ${SRC_ROOT}/cruise-control/scripts/setup_dependent_packages.r"
    exit 1;
fi

Rscript ${SRC_ROOT}/cruise-control/scripts/setup_dependent_packages.r
ret_code=$?
if [ $ret_code != 0 ]; then 
    echo ERROR: Installations of dependencies with setup_dependent_packages.r appears to have FAILED.
    exit $ret_code; 
fi

ret_code=0

for f in ${reponames_bb_checkout[@]} ; do
  cd ${CSIRO_BITBUCKET} \
    && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/numerical-sl-cpp.git \
    && cd numerical-sl-cpp \
    && git checkout reposha["$f"] || ret_code=1;

  if [ $ret_code != 0 ]; then 
    echo ERROR: Failed to clone repository $f
    exit $ret_code; 
  fi
done

# cd ${CSIRO_BITBUCKET} \
#   && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/numerical-sl-cpp.git \
#   && cd numerical-sl-cpp \
#   && git checkout testing \
#   && cd .. \
#   && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/datatypes.git \
#   && cd datatypes \
#   && git checkout testing \
#   && cd .. \
#   && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/swift.git \
#   && cd swift \
#   && git checkout testing \
#   && cd .. \
#   && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/qpp.git \
#   && cd qpp \
#   && git checkout testing \
#   && cd .. \
#   && git clone https://${SWIFT_PAT}@bitbucket.csiro.au/scm/sf/chypp.git \
#   && cd chypp \
#   && git checkout testing \
#   && cd .. || ret_code=1;


# if [ $ret_code != 0 ]; then 
#     echo ERROR: Failed to clone one or more repository on CSIRO git server
#     exit $ret_code; 
# fi

# Clone github repos

ret_code=0
mkdir -p ${GITHUB_REPOS} \
  && cd ${GITHUB_REPOS} \
  && git clone https://github.com/csiro-hydroinformatics/vcpp-commons.git \
  && cd vcpp-commons \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/moirai.git \
  && cd moirai \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/c-interop.git \
  && cd c-interop \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/pyrefcount.git \
  && cd pyrefcount \
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
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/efts-python.git \
  && cd efts-python \
  && git checkout testing \
  && cd .. \
  && git clone https://github.com/csiro-hydroinformatics/mhplot.git \
  && cd mhplot \
  && git checkout master \
  && cd .. || ret_code=1;

if [ $ret_code != 0 ]; then 
    echo ERROR: Failed to clone one or more repository on GitHub git server
    exit $ret_code; 
fi

# TEST_DATA_DIR=${ROOT_OUT_DIR}/tmp/data
TEST_DATA_DIR=${HOME}/tmp/data
mkdir -p ${TEST_DATA_DIR}

cd ${TEST_DATA_DIR}
if [ ! -e swift_test_data.7z ]; then
    curl -o swift_test_data.7z https://cloudstor.aarnet.edu.au/plus/s/RU6kLfzuncINu4f/download
    7z x -y swift_test_data.7z 
fi

export SWIFT_SAMPLE_DATA_DIR=${TEST_DATA_DIR}/documentation


cd ${GITHUB_REPOS}/config-utils \
  && make install

export DEBUG_DEB=0

DEB_BUILD_ROOT=/tmp/debbuild

ret_code=0
cd /internal \
  && chmod +x ./build_debian_pkgs.sh \
  && ./build_debian_pkgs.sh ${DEB_PKGS_DIR} ${SRC_ROOT} ${DEB_BUILD_ROOT} \
  || ret_code=1;

if [ $ret_code == 0 ]; then
    echo "OK: build_debian_pkgs.sh completed with no error";
else
    echo "FAILED: build_debian_pkgs.sh";
    exit $ret_code;
fi

ret_code=0
cd /internal \
  && chmod +x ./build_python_pkgs.sh \
  && ./build_python_pkgs.sh ${PY_PKGS_DIR} ${SRC_ROOT}\
  || ret_code=1;


if [ $ret_code == 0 ]; then
    echo "OK: build_python_pkgs.sh completed with no error";
else
    echo "FAILED: build_python_pkgs.sh";
    exit $ret_code;
fi

ret_code=0

cd /internal \
  && chmod +x ./build_r_pkgs.sh \
  && ./build_r_pkgs.sh ${R_PKGS_DIR} ${SRC_ROOT} \
  || ret_code=1;

if [ $ret_code == 0 ]; then
    echo "OK: build_r_pkgs.sh completed with no error";
else
    echo "FAILED: build_r_pkgs.sh";
    exit $ret_code;
fi

echo "# Streamflow forecasting debian, R and python packages" > README.md
echo "" >> README.md
echo "Built" >> README.md
echo "" >> README.md
echo `date` >> README.md


# Change the ownership of the newly produced files
cd ${ROOT_BUILD_DIR}/
cp -r * /pkgs/
cd /pkgs/
echo "DEBUG: Content of mapped /pkgs/"
ls 
# touch test.txt
chown -R ${CURRENT_UID} *
