# Navonz eDP overlay for NanoPC-T6 (linux-yocto-dev / navonz_v1 profile)
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:nanopc-t6 = "nanopc-t6"

SRC_URI:append:nanopc-t6 = " file://0001-rk3588-navonz-edp-overlay.patch"
