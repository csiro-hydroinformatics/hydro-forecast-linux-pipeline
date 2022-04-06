#!/bin/bash

PY_PKGS_DIR=$1
SRC_ROOT=$2

# PY_PKGS_DIR=${HOME}/tmp/debs
# SRC_ROOT=${HOME}/src

DEBUG_PY=0

mkdir -p ${PY_PKGS_DIR}

pip install wheel twine six pytest
pip install cffi xarray numpy pandas matplotlib jsonpickle
# seaborn?

SUDOCMD=
#SUDOCMD=sudo

_build_py_pkg () {
    if [ ! -e ${PKG_SRC} ]; then
        echo "FAILED: directory not found: $PKG_SRC";
        exit 1;
    fi
    cd $PKG_SRC
    mkdir -p dist
    rm dist/*
    python setup.py sdist bdist_wheel

    if [ $? == 0 ]; then
        echo "OK: built python package $PKG_SRC";
        rm dist/*.tar
        return 0;
    else
        echo "FAILED: building python package $PKG_SRC";
        # cd ${SRC}
        # if [ $DEBUG_PY == 0 ]; then
        #     rm -rf ${DEST_PKG}/*
        # else
        #     echo "DEBUG active: leaving directory $DEST_PKG";
        # fi
        exit 1;
    fi
}


# pip_option="--upgrade"
pip_option=""

#########################################################
SRC=${SRC_ROOT}/pyrefcount
PKG_SRC=${SRC}

_build_py_pkg

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying python wheel to ${PY_PKGS_DIR}";
    cp ${PKG_SRC}/dist/*.whl ${PY_PKGS_DIR}/
fi

${SUDOCMD} pip install ${pip_option} ${PKG_SRC}/dist/*.whl

#########################################################

SRC=${SRC_ROOT}/rcpp-interop-commons
PKG_SRC=${SRC}/bindings/python/cinterop

_build_py_pkg

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying python wheel to ${PY_PKGS_DIR}";
    cp ${PKG_SRC}/dist/*.whl ${PY_PKGS_DIR}/
fi

${SUDOCMD} pip install ${pip_option} ${PKG_SRC}/dist/*.whl

#########################################################


SRC=${SRC_ROOT}/datatypes
PKG_SRC=${SRC}/bindings/python/uchronia

_build_py_pkg

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying python wheel to ${PY_PKGS_DIR}";
    cp ${PKG_SRC}/dist/*.whl ${PY_PKGS_DIR}/
fi

${SUDOCMD} pip install ${pip_option} ${PKG_SRC}/dist/*.whl

#########################################################


SRC=${SRC_ROOT}/swift
PKG_SRC=${SRC}/bindings/python/swift2

_build_py_pkg

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying python wheel to ${PY_PKGS_DIR}";
    cp ${PKG_SRC}/dist/*.whl ${PY_PKGS_DIR}/
fi

${SUDOCMD} pip install ${pip_option} ${PKG_SRC}/dist/*.whl

#########################################################

