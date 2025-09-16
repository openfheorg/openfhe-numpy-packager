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

# ensure that openfhe-numpy.so finds OpenFHE after openfhe-numpy gets installed
patchelf --set-rpath '$ORIGIN:$ORIGIN/../openfhe/lib' ${ONP_ROOT}/openfhe_numpy*.so || true
# echo "------------------ patchelf --print-rpath"
# patchelf --print-rpath ${ONP_ROOT}/openfhe_numpy*.so
# echo "------------------ patchelf --print-rpath"

# add ci-vars.sh as build-config.txt to the wheel for reference
cp ${ROOT}/ci-vars.sh ${ONP_ROOT}/build-config.txt
chmod 644 ${ONP_ROOT}/build-config.txt
cp ${INSTALL_PATH}/__init__.py ${ONP_ROOT}
cp -r ${INSTALL_PATH}/operations/ ${ONP_ROOT}
cp -r ${INSTALL_PATH}/tensor/ ${ONP_ROOT}
cp -r ${INSTALL_PATH}/utils/ ${ONP_ROOT}

cd ${ROOT}
python3 -m build --wheel --outdir ${BUILD_DIR}/dist_temp
# in order to repair the wheel, auditwheel has to have access to libOPENFHE*.so. So, we locate the libs and export LD_LIBRARY_PATH.
# The libs should be in the same directory
OPENFHE_LIBDIR="$(dirname "$(readlink -f "$(find "${BUILD_DIR}" -type f -name 'libOPENFHEpke.so*' -o -name 'libOPENFHEcore.so*' -o -name 'libOPENFHEbinfhe.so*'|head -n1)")")"
# echo "------------------ $OPENFHE_LIBDIR"
# ls -l "$OPENFHE_LIBDIR"/libOPENFHE*.so*
# echo "------------------ $OPENFHE_LIBDIR"
export LD_LIBRARY_PATH="$OPENFHE_LIBDIR:$LD_LIBRARY_PATH"
# auditwheel repair ${BUILD_DIR}/dist_temp/*.whl -w ${BUILD_DIR}/dist

# repair the wheel, but exclude all OpenFHE libs (and libgomp) so they are NOT vendored
# there is an additional auditwheel option required for Ubuntu 20
ADDL_OPTION=$(if [ "$OS_NAME" = "Ubuntu" ] && [ "$OS_RELEASE" = "20.04" ]; then echo "--plat manylinux_2_31_x86_64"; else echo ""; fi)
auditwheel repair $ADDL_OPTION ${BUILD_DIR}/dist_temp/*.whl \
           --exclude libOPENFHEcore.so.1 --exclude libOPENFHEpke.so.1 --exclude libOPENFHEbinfhe.so.1 --exclude libgomp.so \
           -w ${BUILD_DIR}/dist

echo
echo "Done."
