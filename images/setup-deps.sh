#!/bin/bash

umask 022
ROOT_DATA_DIR=/usr/local/share/data

ret_code=0

##################################
# R
##################################

# 202310 we are now installing as root, but probably executing the build on the pipelines 
# as some other user, "vsts_azpcontainer". No root level .Renviron anymore, perhaps in the pipeline though.
#  # Install R dependencies early: something became amiss recently, perhaps with cran.csiro.au
#  # Make sure there is a user Renviron to avoid risks of read-only clash (although theoretical with Docker/jovyan) 
#  if [ ! -e ${HOME}/.Renviron ]; then
#      mkdir -p ${HOME}/R/local
#      echo "R_LIBS=${HOME}/R/local" > $HOME/.Renviron 
#  fi

# Encountered issues when installing on top of R 4.0.4 from Debian Bullseye, starting Sept 2022, if using cran.csiro.au, and probably any other
# Something appears to have changed in the dependencies of a CRAN package, perhaps DiagrammeR or dependency. 
# Instead, using the snapshot kindly provided by Microsoft...

# 2023-06: https://cran.microsoft.com seems down or defunct.
# export CRAN_REPOS="https://cran.microsoft.com/snapshot/2021-02-15"
Rscript ./setup_dependent_packages.r

##################################
# python
##################################

pip install wheel twine six pytest coverage
pip install cffi xarray numpy pandas matplotlib jsonpickle

##################################
# Data for unit tests and docs
##################################

ret_code=0

# Jul 24 suspending or deprecating the use of github lfs. Requires ongoing fee, may make things brittle.
# git lfs install

mkdir -p ${ROOT_DATA_DIR}
# TODO: version the test data in sf-stack repo
# in which case it may be a better idea to clone this repo in the pipeline run
# https://stackoverflow.com/a/45385463/2752565
# if [[ -v "foo[bar]" ]] ; then
#   echo "foo[bar] is set"
# fi

# Jul 24 suspending or deprecating the use of github lfs. Requires ongoing fee, may make things brittle.
# ret_code=0;
# cd ${ROOT_DATA_DIR} \
#   && git clone https://github.com/csiro-hydroinformatics/sf-test-data.git \
#   || ret_code=1;


