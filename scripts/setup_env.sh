#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib_build_dirs.sh
source "${SCRIPT_DIR}/lib_build_dirs.sh"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <platform> <profile>"
    echo "  platform: s905x3, rpi4, rpi0w, or rk3588"
    echo "  profile:  developer, production, or navonz_v1 (rk3588 only)"
    exit 1
fi

PLATFORM=$1
PROFILE=$2
BASE_BUILD_DIR=/home/yocto
BUILD_DIR="$(resolve_build_dir "$PLATFORM" "$PROFILE")"
POKY_DIR="$(resolve_poky_dir "$PLATFORM" "$PROFILE")"

if ! CONFIG_DIR="$(resolve_product_conf_dir "$PLATFORM" "$PROFILE")"; then
    echo ">>> ERROR: config not found for ${PLATFORM}/${PROFILE}"
    echo ">>> Expected: products/${PLATFORM}/${PROFILE}/conf/ or products/${PLATFORM}/conf/"
    exit 1
fi

if [ "$PLATFORM" = "rk3588" ] && [ "$PROFILE" = "navonz_v1" ]; then
    if [ ! -d "/home/yocto/layers-pin/poky" ]; then
        echo ">>> ERROR: layers-pin/ not found. Run: scripts/fetch_layers_pin.sh"
        exit 1
    fi
fi

echo ">>> Build env setup for ${PLATFORM} (${PROFILE})"
echo ">>> Build dir: ${BUILD_DIR}"
echo ">>> Config dir: ${CONFIG_DIR}"
echo ">>> Poky dir: ${POKY_DIR}"

mkdir -p "${BUILD_DIR}/conf"

cp "${CONFIG_DIR}/local.conf" "${BUILD_DIR}/conf/local.conf"
echo ">>> Copied local.conf"

cp "${CONFIG_DIR}/bblayers.conf" "${BUILD_DIR}/conf/bblayers.conf"
echo ">>> Copied bblayers.conf"

if [ -d "${POKY_DIR}" ]; then
    cd "${POKY_DIR}"
    # shellcheck disable=SC1091
    source oe-init-build-env "${BUILD_DIR}" > /dev/null 2>&1 || true
    echo ">>> Build environment initialized"
else
    echo ">>> WARNING: poky not found at ${POKY_DIR}, skipping oe-init-build-env"
fi

if [ "$PLATFORM" = "s905x3" ]; then
    echo ">>> Setting up S905x3 machine config..."
    /home/yocto/scripts/setup_s905x3_machine.sh || echo ">>> WARNING: Failed to setup S905x3 machine config"
fi

echo ">>> Setup complete!"
