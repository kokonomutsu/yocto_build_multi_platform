#!/bin/bash
set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <platform>"
    echo "  platform: s905x3, rpi4, or rpi0w"
    exit 1
fi

PLATFORM=$1
BUILD_DIR=/home/yocto/build-${PLATFORM}

echo ">>> Nuking build directory for ${PLATFORM}..."

if [ -d "${BUILD_DIR}" ]; then
    echo ">>> Removing ${BUILD_DIR}..."
    rm -rf ${BUILD_DIR}
    echo ">>> Build directory removed"
else
    echo ">>> Build directory does not exist, skipping..."
fi

echo ">>> Re-running setup_env.sh..."
./scripts/setup_env.sh ${PLATFORM} developer

echo ">>> Nuke and rebuild setup complete!"
echo ">>> You can now run: scripts/build.sh ${PLATFORM} developer <image>"

