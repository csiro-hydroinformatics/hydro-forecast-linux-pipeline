#!/bin/bash

PY_PKGS_DIR=$1
SRC_ROOT=$2

# PY_PKGS_DIR=${HOME}/tmp/debs
# SRC_ROOT=${HOME}/src

DEBUG_PY=0

. globals

mkdir -p ${PY_PKGS_DIR}

# moved to be set up in base docker image to build from:
# pip install wheel twine six pytest coverage
# pip install cffi xarray numpy pandas matplotlib jsonpickle
# seaborn?

SUDOCMD=
SUDOCMD=sudo

# 2026-04: migrated most of the packages to use pyproject.toml and build with uv. 
# Note: could be made in the base image we build on
curl -LsSf https://astral.sh/uv/install.sh | sh

# To add $HOME/.local/bin to your PATH, either restart your shell or run:
#     source $HOME/.local/bin/env (sh, bash, zsh)
#     source $HOME/.local/bin/env.fish (fish)
source $HOME/.local/bin/env

VENV_PATH=$HOME/.local/venv/swiftbuild
uv venv $VENV_PATH
# check the activate location exists, or exit with error
if [ ! -e $VENV_PATH/bin/activate ]; then
    echo "FAILED: virtual environment not found at $VENV_PATH/bin/activate";
    exit 1;
fi
source $VENV_PATH/bin/activate

echo "uv is at location $(which uv)"
# 2026-10 oddly there is a change of behavior, perhaps with the move to Ubuntu 24-04,
# need to make sure this is is not the system
# level python still active. 
echo "python is at location $(which python)"

_build_py_pkg () {
    if [ ! -e ${PKG_SRC} ]; then
        echo "FAILED: directory not found: $PKG_SRC";
        exit 1;
    fi
    cd $PKG_SRC
    # TODO: placeholder where we should have the unit tests running.
    mkdir -p dist
    rm dist/*
    uv build
    # python3 setup.py sdist bdist_wheel

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

# July 2025, _build_py_pkg assumes a setup.py. No more.:
# _build_py_pkg

# if [ ! $? == 0 ]; then
#     exit 1;
# else
#     echo "OK: copying python wheel to ${PY_PKGS_DIR}";
#     cp ${PKG_SRC}/dist/*.whl ${PY_PKGS_DIR}/
# fi
# July 2025, time to use pypi as the reference for this package:
mkdir -p ${PKG_SRC}/dist/
cd ${PKG_SRC}/dist/
pip download --no-deps refcount
${SUDOCMD} pip install ${pip_option} ${PKG_SRC}/dist/*.whl
echo "OK: copying python wheel to ${PY_PKGS_DIR}";
cp ${PKG_SRC}/dist/*.whl ${PY_PKGS_DIR}/

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
# 2026 04 : temporarily disable. Test harness requires an env per copier-uv with griffe. Overkill for marginal value.
# coverage run -m pytest
# if [ ! $? == 0 ]; then
#     exit 1;
# else
#     echo "OK: uchronia unit tests";
# fi

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

# 2026 04 : temporarily disable. Test harness requires an env per copier-uv with griffe. Overkill for marginal value.
# cd $PKG_SRC
# coverage run -m pytest
# if [ ! $? == 0 ]; then
#     exit 1;
# else
#     echo "OK: swift2 unit tests";
# fi
cd $PKG_SRC/notebooks
# python3 minimal_unit_test.py 
# if [ ! $? == 0 ]; then
#     echo "FAILED: swift2 python3 minimal_unit_test.py";
#     exit 1;
# else
#     echo "OK: swift2 python3 minimal_unit_test.py";
# fi

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


SRC=${SRC_ROOT}/swift-py-dev

# 2026-10 we have a template toml otherwise many conflicts amongst users
# THis may be superseded by a more elegant handling of user and machine specific configuration in the future.
cd $SRC
cp pyproject.toml.template pyproject.toml

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

