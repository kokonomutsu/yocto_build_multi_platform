#!/bin/bash
set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <platform>"
    echo "  platform: s905x3 or rpi4"
    exit 1
fi

PLATFORM=$1
BUILD_DIR=/home/yocto/build-${PLATFORM}
DOWNLOADS_DIR=/home/yocto/downloads

echo ">>> Fetching missing sources for ${PLATFORM}..."

if [ ! -d "/home/yocto/layers/poky" ]; then
    echo ">>> ERROR: poky layer not found!"
    exit 1
fi

cd /home/yocto/layers/poky
source oe-init-build-env ${BUILD_DIR} > /dev/null 2>&1

# Fetch all sources
echo ">>> Running bitbake to fetch sources..."
bitbake -c fetchall core-image-minimal || true

echo ">>> Source fetching complete!"
echo ">>> Sources are in: ${DOWNLOADS_DIR}"

