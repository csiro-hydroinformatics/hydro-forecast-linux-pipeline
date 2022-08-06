#!/bin/bash

# If az login or az devops login haven't been used, all az devops commands 
# will try to sign in using a PAT stored in the AZURE_DEVOPS_EXT_PAT environment variable.
# To use a PAT, set the AZURE_DEVOPS_EXT_PAT environment variable at the process level.

# Need to do this; from cron job .bashrc not read, it seems.
if [ -f ${HOME}/.creds/.az_pat_dwl_swift ]; then
    . ${HOME}/.creds/.az_pat_dwl_swift
fi

wd=$1

${HOME}/src/config-utils/automation/az-artifact-dl.sh $wd swift_deb swift_deb_version hydro_forecast_deb https://dev.azure.com/OD222236-DigWaterAndLandscapes OD222236-DigWaterAndLandscapes
