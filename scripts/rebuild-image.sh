#!/bin/bash
set -e

if [ $# -lt 3 ]; then
    echo "Usage: $0 <platform> <profile> <image>"
    echo "  platform: s905x3 or rpi4"
    echo "  profile: developer or production"
    echo "  image: core-image-minimal, core-image-base, etc."
    exit 1
fi

PLATFORM=$1
PROFILE=$2
IMAGE=$3
BUILD_DIR=/home/yocto/build-${PLATFORM}

echo ">>> Rebuilding ${IMAGE} for ${PLATFORM}..."

# Clean the specific image
if [ -d "/home/yocto/layers/poky" ]; then
    cd /home/yocto/layers/poky
    source oe-init-build-env ${BUILD_DIR} > /dev/null 2>&1
    
    echo ">>> Cleaning ${IMAGE}..."
    bitbake -c cleanall ${IMAGE}
    
    echo ">>> Rebuilding ${IMAGE}..."
    ./scripts/build.sh ${PLATFORM} ${PROFILE} ${IMAGE}
else
    echo ">>> ERROR: poky layer not found!"
    exit 1
fi

