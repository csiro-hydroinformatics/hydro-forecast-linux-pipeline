#!/bin/bash

# If az login or az devops login haven't been used, all az devops commands 
# will try to sign in using a PAT stored in the AZURE_DEVOPS_EXT_PAT environment variable.
# To use a PAT, set the AZURE_DEVOPS_EXT_PAT environment variable at the process level.

# Need to do this; from cron job .bashrc not read, it seems.
if [ -f ${HOME}/.creds/.az_pat_dwl_swift ]; then
    . ${HOME}/.creds/.az_pat_dwl_swift
fi

if [ ! -z ${AZURE_DEVOPS_EXT_PAT+x} ]; then
    echo "INFO variable AZURE_DEVOPS_EXT_PAT already defined";
else
    echo "ERROR env variable AZURE_DEVOPS_EXT_PAT must be defined";
    exit 1

fi

wd=${HOME}/swift_setup

swift_current_version_dir=${wd}/swift_setup_version_current
swift_setup_version_dir=${wd}/swift_setup_version
swift_setup_dir=${wd}/swift_setup/latest

mkdir -p $swift_current_version_dir
mkdir -p $swift_setup_version_dir
mkdir -p $swift_setup_dir

if [ ! -f ${swift_current_version_dir}/version.txt ]; then
    echo "0.0.1" > ${swift_current_version_dir}/version.txt
fi

# vercomp: license: cc-by-sa 
# credits: https://stackoverflow.com/a/4025065
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

_download_version () {

    az artifacts universal download --organization https://dev.azure.com/OD222236-DigWaterAndLandscapes --scope project --project "OD222236-DigWaterAndLandscapes" --feed "hydro_forecast_deb" --name "swift_deb_version" --version "*" --path ${swift_setup_version_dir}

    if [ $? == 0 ]; then
        return 0;
    else
        echo "FAILED: swift_setup_version download";
        return 1;
    fi
}

_download_setup () {

    az artifacts universal download --organization https://dev.azure.com/OD222236-DigWaterAndLandscapes --scope project --project "OD222236-DigWaterAndLandscapes" --feed "hydro_forecast_deb" --name "swift_deb" --version "*" --path ${swift_setup_dir}

    if [ $? == 0 ]; then
        return 0;
    else
        echo "FAILED: swift_setup download";
        return 1;
    fi
}

_download_version
if [ ! $? == 0 ]; then
    exit 1;
fi

currentver=`cat ${swift_current_version_dir}/version.txt`
newver=`cat ${swift_setup_version_dir}/version.txt`

vercomp $currentver $newver
case $? in
    0) op='=';;
    1) op='>';;
    2) op='<';;
esac

if [[ $op != '<' ]]
then
    echo "Version number already the latest: $currentver"
    #exit 0;
else
    echo "Newer version available: $newver"
    rm ${swift_setup_dir}/*.*
    _download_setup
    if [ ! $? == 0 ]; then
        exit 1;
    fi
    # and we end up by setting the current version.
    echo $newver > ${swift_current_version_dir}/version.txt
    exit 0;
fi
