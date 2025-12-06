#!/bin/bash
# Setup machine config for amlogic-s905x3 in meta-meson layer

set -e

MACHINE_CONF="/home/yocto/layers/meta-meson/conf/machine/amlogic-s905x3.conf"

if [ ! -f "$MACHINE_CONF" ]; then
    echo ">>> Creating amlogic-s905x3 machine config..."
    cat > "$MACHINE_CONF" << 'INNER_EOF'
#@TYPE: Machine
#@NAME: Amlogic S905X3 Generic Machine
#@DESCRIPTION: Machine configuration for Amlogic S905X3 (SM1 family)
# Supports G12A/G12B/SM1 (S905X3 is SM1)

require conf/machine/include/amlogic-s905x3.inc
require conf/machine/include/amlogic-modern-boot.inc

MACHINE_FEATURES:append = " alsa ext2 screen usbgadget usbhost sdio vfat"

UBOOT_MACHINE = "odroid-c4_defconfig"
INNER_EOF
    echo ">>> Machine config created: $MACHINE_CONF"
else
    echo ">>> Machine config already exists: $MACHINE_CONF"
fi
