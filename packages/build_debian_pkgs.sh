#!/bin/bash

# directory where to put all the finalised .deb files
DEB_PKGS_DIR=$1
# Root of the source directory, where all the checked out repositories are
SRC_ROOT=$2
# temporary, working directory where pkgs are built
DEB_BUILD_ROOT=$3

# DEB_PKGS_DIR=${HOME}/tmp/debs
# SRC_ROOT=${HOME}/src
# DEB_BUILD_ROOT=${HOME}/tmp/debbuild

DEBUG_DEB=0

mkdir -p ${DEB_PKGS_DIR}
mkdir -p ${DEB_BUILD_ROOT}

SUDOCMD=
# for testing on a local machine:
#SUDOCMD=sudo

_clean_debbuild() {
    cd $SRC
    rm -rf ${DEB_BUILD_PKG}/*
}

_build_tarball () {
    src_pkgname=$1
    vernum=$2
    SRC=$3
    FILES=$4
    if [ ! -e ${SRC} ]; then
        echo "FAILED: directory not found: $SRC";
        exit 1;
    fi
    src_pkgname_ver=${src_pkgname}-${vernum}
    src_pkgname_orig_directory=${src_pkgname_ver}
    fn_ver=${src_pkgname}_${vernum}
    DEB_BUILD_PKG=${DEB_BUILD_ROOT}/${src_pkgname}/
    DEB_BUILD=${DEB_BUILD_PKG}/${src_pkgname}/${src_pkgname_orig_directory}
    if [ $DEBUG_DEB == 0 ]; then
        if [ -e ${DEB_BUILD} ]; then
            echo "OK?: Found existing directory $DEB_BUILD ; Assuming this is already built";
            return 0;
        fi
    fi
    mkdir -p ${DEB_BUILD_PKG}
    rm -rf ${DEB_BUILD_PKG}/*
    mkdir -p ${DEB_BUILD}
    cd ${SRC}
    cp -Rf ${FILES} ${DEB_BUILD}/
    cd ${DEB_BUILD}
    # ls -a
    cd ${DEB_BUILD}/..
    tar -zcvf ${fn_ver}.orig.tar.gz ${src_pkgname_orig_directory}
    cd ${DEB_BUILD}
    debuild -us -uc 
    if [ $? == 0 ]; then
        echo "OK: built $src_pkgname";
        return 0;
    else
        echo "FAILED: $src_pkgname";
        cd ${SRC}
        if [ $DEBUG_DEB == 0 ]; then
            rm -rf ${DEB_BUILD_PKG}/*
        else
            echo "DEBUG active: leaving directory $DEB_BUILD_PKG";
        fi
        exit 1;
    fi
}

_checked_build_tarball () {
    _build_tarball $1 $2 $3 "$4";
    if [ ! $? == 0 ]; then
        exit 1;
    else
        echo "OK: copying to ${DEB_PKGS_DIR}";
        cp ${DEB_BUILD}/../*.deb ${DEB_PKGS_DIR}/ ;
    fi
}


_install_deb() {
    libname=$1
    deb_version=$2
    # dpkg -c ${DEB_PKGS_DIR}/lib${src_pkgname}-dev_${deb_version}_amd64.deb
    ${SUDOCMD} dpkg -i ${DEB_PKGS_DIR}/${libname}_${deb_version}_amd64.deb
    if [ ! $? == 0 ]; then
        echo "FAILED: installing ${libname}";
        exit 1;
    fi
}

#########################################################


src_pkgname=moirai
vernum=1.0
SRC=${SRC_ROOT}/moirai
FILES="CMakeLists.txt cmake_uninstall.cmake.in src include debian/ doc/ tests moirai.pc.in README.md"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname} $deb_version
_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=cinterop
vernum=1.1
SRC=${SRC_ROOT}/rcpp-interop-commons
FILES="cinterop.pc.in CMakeLists.txt cmake_uninstall.cmake.in debian/ doc/ include/ LICENSE.txt README.md"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=boost-threadpool
vernum=0.2
SRC=${SRC_ROOT}/threadpool
FILES="boost  boost-thread.pc.in  CHANGE_LOG  COPYING  debian  docs  Jamfile.v2  Jamrules  libs  LICENSE_1_0.txt  Makefile  project-root.jam  README  TODO"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=wila
vernum=0.7
SRC=${SRC_ROOT}/wila
FILES="CMakeLists.txt  cmake_uninstall.cmake.in  debian/  doc/  FindTBB.cmake  include/  LICENSE  README.md  tests/  wila.kdev4  wila.pc.in wila.props.in"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=sfsl
vernum=2.3
SRC=${SRC_ROOT}/numerical-sl-cpp
FILES="algorithm  CMakeLists.txt  cmake_uninstall.cmake.in  debian math  README.md  sfsl.pc.in test"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=uchronia
vernum=2.3
SRC=${SRC_ROOT}/datatypes/datatypes
FILES="CMakeLists.txt cmake_uninstall.cmake.in include src debian lib_paths.props.in tests uchronia.pc.in version.cmake"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname} $deb_version
_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=swift
vernum=2.3
SRC=${SRC_ROOT}/swift/libswift
FILES="CMakeLists.txt cmake_uninstall.cmake.in workarounds.h *.cpp debian tests swift.pc.in include/"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname} $deb_version
_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=qppcore
vernum=2.3
SRC=${SRC_ROOT}/qpp/libqppcore
FILES="CMakeLists.txt cmake_uninstall.cmake.in *.cpp debian qppcore.pc.in include/"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname} $deb_version
_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

src_pkgname=qpp
vernum=2.3
SRC=${SRC_ROOT}/qpp/libqpp
FILES="CMakeLists.txt cmake_uninstall.cmake.in *.cpp debian qpp.pc.in include/"
deb_version=`dpkg-parsechangelog --show-field Version -l ${SRC}/debian/changelog`

_checked_build_tarball $src_pkgname $vernum $SRC "$FILES"

_install_deb() lib${src_pkgname} $deb_version
_install_deb() lib${src_pkgname}-dev $deb_version

#########################################################

