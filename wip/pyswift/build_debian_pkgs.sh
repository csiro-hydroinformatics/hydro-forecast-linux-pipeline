#!/bin/bash

DEB_PKGS_DIR=$1
SRC_ROOT=$2
DEST_ROOT=$3

# DEB_PKGS_DIR=${HOME}/tmp/debs
# SRC_ROOT=${HOME}/src
# DEST_ROOT=${HOME}/tmp/debbuild

DEBUG_DEB=0

mkdir -p ${DEB_PKGS_DIR}
mkdir -p ${DEST_ROOT}

SUDOCMD=
#SUDOCMD=sudo

_clean_debbuild() {
    cd $SRC
    rm -rf ${DEST_PKG}/*
}

_build_tarball () {
    if [ ! -e ${SRC} ]; then
        echo "FAILED: directory not found: $SRC";
        exit 1;
    fi
    src_pkgname_ver=${src_pkgname}-${vernum}
    src_pkgname_orig_directory=${src_pkgname_ver}
    fn_ver=${src_pkgname}_${vernum}
    DEST_PKG=${DEST_ROOT}/${src_pkgname}/
    DEST=${DEST_PKG}/${src_pkgname}/${src_pkgname_orig_directory}
    if [ $DEBUG_DEB == 0 ]; then
        if [ -e ${DEST} ]; then
            echo "OK?: Found existing directory $DEST ; Assuming this is already built";
            return 0;
        fi
    fi
    mkdir -p ${DEST_PKG}
    rm -rf ${DEST_PKG}/*
    mkdir -p ${DEST}
    cd ${SRC}
    cp -Rf ${FILES} ${DEST}/
    cd ${DEST}
    # ls -a
    cd ${DEST}/..
    tar -zcvf ${fn_ver}.orig.tar.gz ${src_pkgname_orig_directory}
    cd ${DEST}
    debuild -us -uc 
    if [ $? == 0 ]; then
        echo "OK: built $src_pkgname";
        return 0;
    else
        echo "FAILED: $src_pkgname";
        cd ${SRC}
        if [ $DEBUG_DEB == 0 ]; then
            rm -rf ${DEST_PKG}/*
        else
            echo "DEBUG active: leaving directory $DEST_PKG";
        fi
        exit 1;
    fi
}

#########################################################

src_pkgname=moirai
vernum=1.0
SRC=${SRC_ROOT}/moirai/
FILES="CMakeLists.txt cmake_uninstall.cmake.in src include debian/ doc/ tests moirai.pc.in README.md"

_build_tarball
if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying to ${DEB_PKGS_DIR}";
    cp ${DEST}/../*.deb ${DEB_PKGS_DIR}/
fi

${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libmoirai_1.0-1_amd64.deb
${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libmoirai-dev_1.0-1_amd64.deb

#########################################################

src_pkgname=cinterop
vernum=1.1
SRC=${SRC_ROOT}/c-interop
FILES="cinterop.pc.in CMakeLists.txt cmake_uninstall.cmake.in debian/ doc/ include/ LICENSE.txt README.md"
_build_tarball

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying to ${DEB_PKGS_DIR}";
    cp ${DEST}/../*.deb ${DEB_PKGS_DIR}/
fi

${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libcinterop-dev_1.1-1_amd64.deb

#########################################################

src_pkgname=boost-threadpool
vernum=0.2
SRC=${SRC_ROOT}/threadpool
FILES="boost  boost-thread.pc.in  CHANGE_LOG  COPYING  debian  docs  Jamfile.v2  Jamrules  libs  LICENSE_1_0.txt  Makefile  project-root.jam  README  TODO"
_build_tarball

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying to ${DEB_PKGS_DIR}";
    cp ${DEST}/../*.deb ${DEB_PKGS_DIR}/
fi

dpkg -c ${DEB_PKGS_DIR}/libboost-threadpool-dev_0.2-6_amd64.deb
${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libboost-threadpool-dev_0.2-6_amd64.deb

#########################################################

src_pkgname=wila
vernum=0.7
SRC=${SRC_ROOT}/wila
FILES="CMakeLists.txt  cmake_uninstall.cmake.in  debian/  doc/  FindTBB.cmake  include/  LICENSE  README.md  tests/  wila.kdev4  wila.pc.in wila.props.in"
_build_tarball

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying to ${DEB_PKGS_DIR}";
    cp ${DEST}/../*.deb ${DEB_PKGS_DIR}/
fi

dpkg -c ${DEB_PKGS_DIR}/libwila-dev_0.7-1_amd64.deb 
${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libwila-dev_0.7-1_amd64.deb 

#########################################################

src_pkgname=sfsl
vernum=2.3
SRC=${SRC_ROOT}/numerical-sl-cpp
FILES="algorithm  CMakeLists.txt  cmake_uninstall.cmake.in  debian math  README.md  sfsl.pc.in test"
_build_tarball

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying to ${DEB_PKGS_DIR}";
    cp ${DEST}/../*.deb ${DEB_PKGS_DIR}/
fi

dpkg -c ${DEB_PKGS_DIR}/libsfsl-dev_2.3-1_amd64.deb
${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libsfsl-dev_2.3-1_amd64.deb

#########################################################

src_pkgname=uchronia
vernum=2.3
SRC=${SRC_ROOT}/datatypes/datatypes
FILES="CMakeLists.txt cmake_uninstall.cmake.in include src debian lib_paths.props.in tests uchronia.pc.in version.cmake"
_build_tarball

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying to ${DEB_PKGS_DIR}";
    cp ${DEST}/../*.deb ${DEB_PKGS_DIR}/
fi

dpkg -c ${DEB_PKGS_DIR}/libuchronia_2.3-1_amd64.deb 
dpkg -c ${DEB_PKGS_DIR}/libuchronia-dev_2.3-1_amd64.deb 

${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libuchronia_2.3-1_amd64.deb 
${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libuchronia-dev_2.3-1_amd64.deb 

#########################################################

src_pkgname=swift
vernum=2.3
SRC=${SRC_ROOT}/swift/libswift
FILES="CMakeLists.txt cmake_uninstall.cmake.in workarounds.h *.cpp debian tests swift.pc.in include/"
_build_tarball

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying to ${DEB_PKGS_DIR}";
    cp ${DEST}/../*.deb ${DEB_PKGS_DIR}/
fi

dpkg -c ${DEB_PKGS_DIR}/libswift_2.3-7_amd64.deb 
dpkg -c ${DEB_PKGS_DIR}/libswift-dev_2.3-7_amd64.deb 

${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libswift_2.3-7_amd64.deb 
${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/libswift-dev_2.3-7_amd64.deb 

