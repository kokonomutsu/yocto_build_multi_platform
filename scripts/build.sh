#!/bin/bash
set -e

if [ $# -lt 3 ]; then
    echo "Usage: $0 <platform> <profile> <image>"
    echo "  platform: s905x3, rpi4, or rpi0w"
    echo "  profile: developer or production"
    echo "  image: core-image-minimal, core-image-base, etc."
    exit 1
fi

PLATFORM=$1
PROFILE=$2
IMAGE=$3
BASE_DIR=/home/yocto
BUILD_DIR=$BASE_DIR/build-${PLATFORM}
LOG_DIR=$BASE_DIR/logs

mkdir -p ${LOG_DIR}

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE=${LOG_DIR}/build-${PLATFORM}-${IMAGE}-${TIMESTAMP}.log

echo ">>> Starting build: ${PLATFORM} - ${IMAGE}"
echo ">>> Log file: ${LOG_FILE}"

# Initialize build environment
if [ ! -d "/home/yocto/layers/poky" ]; then
    echo ">>> ERROR: poky layer not found! Run fetch_layers.sh first."
    exit 1
fi

cd /home/yocto/layers/poky
source oe-init-build-env ${BUILD_DIR} > /dev/null 2>&1

# Start build
echo ">>> Building ${IMAGE} for ${PLATFORM}..."
bitbake ${IMAGE} 2>&1 | tee ${LOG_FILE}

BUILD_STATUS=${PIPESTATUS[0]}

if [ ${BUILD_STATUS} -eq 0 ]; then
    echo ">>> Build completed successfully!"
    echo ">>> Image location: ${BUILD_DIR}/tmp/deploy/images/"
else
    echo ">>> Build failed with exit code: ${BUILD_STATUS}"
    echo ">>> Check log file: ${LOG_FILE}"
    exit ${BUILD_STATUS}
fi

