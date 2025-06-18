#!/bin/sh

. ./ci-vars.sh
. ./scripts/common-functions.sh

# WHEEL [OUTPUT] VERSION
WHEEL_VERSION=$(get_wheel_version ${OS_RELEASE} ${OPENFHE_NUMPY_TAG} ${WHEEL_MINOR_VERSION} ${WHEEL_TEST_VERSION})
if [ -z "$WHEEL_VERSION" ]; then
  abort "${0}: WHEEL_VERSION has not been specified."
fi

# =============================================================================
#
ROOT=$(pwd)
BUILD_DIR=${ROOT}/build
echo "${0}: BUILD_DIR - ${BUILD_DIR}"

# separator
# echo "OPENFHE_PYTHON WHEEL BUILD PARAMETERS"
# echo
# echo "WHEEL_VERSION      : " ${WHEEL_VERSION}
# separator

# ASSEMBLE WHEEL ROOT FILESYSTEM
cd ${BUILD_DIR} # should be redundant
WHEEL_ROOT="${BUILD_DIR}/wheel-root"
rm -r ${WHEEL_ROOT}
mkdir -p ${WHEEL_ROOT}

ONP_ROOT="${WHEEL_ROOT}/openfhe_numpy"
mkdir -p ${ONP_ROOT}
# mkdir -p ${ONP_ROOT}/openfhe
# mkdir -p ${ONP_ROOT}/openfhe/lib

# echo "OPENFHE_PYTHON module"
# INSTALL_PATH=$(get_openfhe_install_path ${BUILD_DIR})
# # add openfhe.*.so to the wheel (openfhe-python's .so)
# cp ${INSTALL_PATH}/openfhe.*.so ${ONP_ROOT}/openfhe
# # add libOPENFHE*.so to the wheel
# echo "OPENFHE libraries"
# cp ${INSTALL_PATH}/lib/*.so.1 ${ONP_ROOT}/openfhe/lib

# # add __init__.py to the wheel
# cp ${INSTALL_PATH}/__init__.py ${ONP_ROOT}/openfhe

############################################################################
### Adding all necessary libraries
############################################################################
# echo "Adding libgomp.so ..."
# CXX_COMPILER=$(get_compiler_version "g++")
# libgomp_path=$(${CXX_COMPILER} -print-file-name=libgomp.so)
# # Check if the returned string is a path (i.e., not just "libgomp.so")
# if [ "${libgomp_path}" != "libgomp.so" ]; then
#     echo "libgomp for ${CXX_COMPILER} found at: ${libgomp_path}"
# else
#     echo "ERROR: libgomp not found for ${CXX_COMPILER}."
#     exit 1
# fi
# cp ${libgomp_path} ${ONP_ROOT}/openfhe/lib
separator

echo "OPENFHE-NUMPY module"
INSTALL_PATH=$(get_install_path ${BUILD_DIR})
cp ${INSTALL_PATH}/openfhe_numpy.*.so ${ONP_ROOT}
# add ci-vars.sh as build-config.txt to the wheel for reference
cp ${ROOT}/ci-vars.sh ${ONP_ROOT}/build-config.txt
chmod 644 ${ONP_ROOT}/build-config.txt
cp ${INSTALL_PATH}/__init__.py ${ONP_ROOT}
cp -r ${INSTALL_PATH}/operations/ ${ONP_ROOT}
cp -r ${INSTALL_PATH}/tensor/ ${ONP_ROOT}
cp -r ${INSTALL_PATH}/utils/ ${ONP_ROOT}
# touch ${ONP_ROOT}/__init__.py # TODO (dsuponit): this should be in openfhe-numpy

cd ${ROOT}
python3 -m build --wheel --outdir ${BUILD_DIR}/dist

echo
echo "Done."
