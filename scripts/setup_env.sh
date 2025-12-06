#!/bin/bash
set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <platform> <profile>"
    echo "  platform: s905x3, rpi4, or rpi0w"
    echo "  profile: developer or production"
    exit 1
fi

PLATFORM=$1
PROFILE=$2
BASE_BUILD_DIR=/home/yocto
BUILD_DIR=$BASE_BUILD_DIR/build-${PLATFORM}
PRODUCT_DIR=$BASE_BUILD_DIR/products/${PLATFORM}

echo ">>> Build env setup for ${PLATFORM} (${PROFILE})"
echo ">>> Build dir: ${BUILD_DIR}"

# Create build directory
mkdir -p ${BUILD_DIR}/conf

# Copy config files from product template
if [ -f "${PRODUCT_DIR}/conf/local.conf" ]; then
    cp ${PRODUCT_DIR}/conf/local.conf ${BUILD_DIR}/conf/local.conf
    echo ">>> Copied local.conf"
else
    echo ">>> ERROR: ${PRODUCT_DIR}/conf/local.conf not found!"
    exit 1
fi

if [ -f "${PRODUCT_DIR}/conf/bblayers.conf" ]; then
    cp ${PRODUCT_DIR}/conf/bblayers.conf ${BUILD_DIR}/conf/bblayers.conf
    echo ">>> Copied bblayers.conf"
else
    echo ">>> ERROR: ${PRODUCT_DIR}/conf/bblayers.conf not found!"
    exit 1
fi

# Initialize build environment (if poky exists)
if [ -d "/home/yocto/layers/poky" ]; then
    cd /home/yocto/layers/poky
    source oe-init-build-env ${BUILD_DIR} > /dev/null 2>&1 || true
    echo ">>> Build environment initialized"
else
    echo ">>> WARNING: poky layer not found, skipping oe-init-build-env"
fi

# Setup S905x3 machine config if needed
if [ "$PLATFORM" = "s905x3" ]; then
    echo ">>> Setting up S905x3 machine config..."
    /home/yocto/scripts/setup_s905x3_machine.sh || echo ">>> WARNING: Failed to setup S905x3 machine config"
fi

# Use default TMPDIR for system stability
# (RAM disk has been disabled to prevent system crashes)

echo ">>> Setup complete!"

