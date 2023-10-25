#!/bin/bash
SRC_ROOT=/src
ret_code=0

##################################
# R
##################################

# Install R dependencies early: something became amiss recently, perhaps with cran.csiro.au
# Make sure there is a user Renviron to avoid risks of read-only clash (although theoretical with Docker/jovyan) 
if [ ! -e ${HOME}/.Renviron ]; then
    mkdir -p ${HOME}/R/local
    echo "R_LIBS=${HOME}/R/local" > $HOME/.Renviron 
fi

# Encountered issues when installing on top of R 4.0.4 from Debian Bullseye, starting Sept 2022, if using cran.csiro.au, and probably any other
# Something appears to have changed in the dependencies of a CRAN package, perhaps DiagrammeR or dependency. 
# Instead, using the snapshot kindly provided by Microsoft...

# 2023-06: https://cran.microsoft.com seems down or defunct.
# export CRAN_REPOS="https://cran.microsoft.com/snapshot/2021-02-15"
Rscript ./setup_dependent_packages.r

ret_code=0

# TEST_DATA_DIR=${ROOT_OUT_DIR}/tmp/data
TEST_DATA_DIR=${HOME}/tmp/data
mkdir -p ${TEST_DATA_DIR}

cd ${TEST_DATA_DIR}
if [ ! -e swift_test_data.7z ]; then
    curl -o swift_test_data.7z https://cloudstor.aarnet.edu.au/plus/s/RU6kLfzuncINu4f/download
    7z x -y swift_test_data.7z 
fi


##################################
# python
##################################

pip install wheel twine six pytest coverage
pip install cffi xarray numpy pandas matplotlib jsonpickle
