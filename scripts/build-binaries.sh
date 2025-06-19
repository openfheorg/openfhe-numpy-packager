#!/bin/sh

. ./ci-vars.sh
. ./scripts/common-functions.sh

ROOT=$(pwd)
BUILD_DIR=${ROOT}/build
echo "${0}: BUILD_DIR - ${BUILD_DIR}"

### build openfhe-numpy
OPENFHE_NUMPY_REPO="https://github.com/openfheorg/openfhe-numpy.git"
OPENFHE_NUMPY_DIR="${BUILD_DIR}/openfhe-numpy"
OPENFHE_NUMPY_CMAKE_ARGS=$(get_cmake_default_args ${BUILD_DIR})
echo "OPENFHE_NUMPY_CMAKE_ARGS: ${OPENFHE_NUMPY_CMAKE_ARGS}"

clone ${OPENFHE_NUMPY_REPO} ${OPENFHE_NUMPY_DIR}
build_install_tag_with_args ${OPENFHE_NUMPY_DIR} ${OPENFHE_NUMPY_TAG} "${OPENFHE_NUMPY_CMAKE_ARGS}" ${PARALELLISM}

separator

