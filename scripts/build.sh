#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib_build_dirs.sh
source "${SCRIPT_DIR}/lib_build_dirs.sh"

if [ $# -lt 3 ]; then
    echo "Usage: $0 <platform> <profile> <image>"
    echo "  platform: s905x3, rpi4, rpi0w, or rk3588"
    echo "  profile:  developer, production, or navonz_v1 (rk3588 only)"
    echo "  image:    core-image-minimal, core-image-base, etc."
    exit 1
fi

PLATFORM=$1
PROFILE=$2
IMAGE=$3
BASE_DIR=/home/yocto
BUILD_DIR="$(resolve_build_dir "$PLATFORM" "$PROFILE")"
POKY_DIR="$(resolve_poky_dir "$PLATFORM" "$PROFILE")"
LOG_DIR=$BASE_DIR/logs
LOG_PREFIX="$(resolve_build_log_prefix "$PLATFORM" "$PROFILE")"

mkdir -p "${LOG_DIR}"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE=${LOG_DIR}/${LOG_PREFIX}-${IMAGE}-${TIMESTAMP}.log

echo ">>> Starting build: ${PLATFORM} (${PROFILE}) - ${IMAGE}"
echo ">>> Build dir: ${BUILD_DIR}"
echo ">>> Log file: ${LOG_FILE}"

if [ ! -d "${POKY_DIR}" ]; then
    echo ">>> ERROR: poky not found at ${POKY_DIR}"
    if [ "$PLATFORM" = "rk3588" ] && [ "$PROFILE" = "navonz_v1" ]; then
        echo ">>> Run: scripts/fetch_layers_pin.sh"
    else
        echo ">>> Run: scripts/fetch_layers.sh"
    fi
    exit 1
fi

cd "${POKY_DIR}"
# shellcheck disable=SC1091
source oe-init-build-env "${BUILD_DIR}" > /dev/null 2>&1

echo ">>> Building ${IMAGE} for ${PLATFORM} (${PROFILE})..."
bitbake "${IMAGE}" 2>&1 | tee "${LOG_FILE}"

BUILD_STATUS=${PIPESTATUS[0]}

if [ ${BUILD_STATUS} -eq 0 ]; then
    echo ">>> Build completed successfully!"
    echo ">>> Image location: ${BUILD_DIR}/tmp/deploy/images/"
else
    echo ">>> Build failed with exit code: ${BUILD_STATUS}"
    echo ">>> Check log file: ${LOG_FILE}"
    exit ${BUILD_STATUS}
fi
