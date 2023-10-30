#!/bin/bash

PY_PKGS_DIR=$1
SRC_ROOT=$2

# PY_PKGS_DIR=${HOME}/tmp/debs
# SRC_ROOT=${HOME}/src

DEBUG_PY=0

mkdir -p ${PY_PKGS_DIR}

# moved to be set up in base docker image to build from:
# pip install wheel twine six pytest coverage
# pip install cffi xarray numpy pandas matplotlib jsonpickle
# seaborn?

SUDOCMD=
SUDOCMD=sudo

_build_py_pkg () {
    if [ ! -e ${PKG_SRC} ]; then
        echo "FAILED: directory not found: $PKG_SRC";
        exit 1;
    fi
    cd $PKG_SRC
    # TODO: placeholder where we should have the unit tests running.
    mkdir -p dist
    rm dist/*
    python3 setup.py sdist bdist_wheel

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

SRC=${SRC_ROOT}/c-interop
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

cd $PKG_SRC
coverage run -m pytest
if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: uchronia unit tests";
fi

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

# cd $PKG_SRC
# coverage run -m pytest
# if [ ! $? == 0 ]; then
#     exit 1;
# else
#     echo "OK: swift2 unit tests";
# fi
cd $PKG_SRC/notebooks
python3 minimal_unit_test.py 
if [ ! $? == 0 ]; then
    echo "FAILED: swift2 python3 minimal_unit_test.py";
    exit 1;
else
    echo "OK: swift2 python3 minimal_unit_test.py";
fi

#########################################################


SRC=${SRC_ROOT}/qpp
PKG_SRC=${SRC}/bindings/python/fogss

_build_py_pkg

if [ ! $? == 0 ]; then
    exit 1;
else
    echo "OK: copying python wheel to ${PY_PKGS_DIR}";
    cp ${PKG_SRC}/dist/*.whl ${PY_PKGS_DIR}/
fi

${SUDOCMD} pip install ${pip_option} ${PKG_SRC}/dist/*.whl

#########################################################

