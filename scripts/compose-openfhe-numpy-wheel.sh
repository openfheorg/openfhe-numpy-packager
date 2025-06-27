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

# ASSEMBLE WHEEL ROOT FILESYSTEM
cd ${BUILD_DIR} # should be redundant
WHEEL_ROOT="${BUILD_DIR}/wheel-root"
rm -r ${WHEEL_ROOT}
mkdir -p ${WHEEL_ROOT}

ONP_ROOT="${WHEEL_ROOT}/openfhe_numpy"
mkdir -p ${ONP_ROOT}
separator

echo "OPENFHE-NUMPY module"
INSTALL_PATH=$(get_install_path ${BUILD_DIR})/openfhe-numpy
cp ${INSTALL_PATH}/openfhe_numpy.*.so ${ONP_ROOT}
# add ci-vars.sh as build-config.txt to the wheel for reference
cp ${ROOT}/ci-vars.sh ${ONP_ROOT}/build-config.txt
chmod 644 ${ONP_ROOT}/build-config.txt
cp ${INSTALL_PATH}/__init__.py ${ONP_ROOT}
cp -r ${INSTALL_PATH}/operations/ ${ONP_ROOT}
cp -r ${INSTALL_PATH}/tensor/ ${ONP_ROOT}
cp -r ${INSTALL_PATH}/utils/ ${ONP_ROOT}

cd ${ROOT}
python3 -m build --wheel --outdir ${BUILD_DIR}/dist

echo
echo "Done."
