#!/bin/bash
# Fetch pinned layers for rk3588 navonz_v1 into layers-pin/ (host or Docker).
set -e

BASE_DIR=/home/yocto
LAYERS_PIN_DIR="${BASE_DIR}/layers-pin"

POKY_URL="https://git.yoctoproject.org/git/poky"
POKY_SHA="1dec53b350d7d2edcc880f640b1cb2fd31ff7f0b"

META_OE_URL="https://git.openembedded.org/meta-openembedded"
META_OE_SHA="fd6a9a2b30fab61c3761b42110b37512756f3525"

META_ARM_URL="https://git.yoctoproject.org/git/meta-arm"
META_ARM_SHA="a3a2c49b2149606f314b2ee0aeba7d6becd12545"

META_ROCKCHIP_URL="https://git.yoctoproject.org/git/meta-rockchip"
META_ROCKCHIP_SHA="4fdc16878efb6e1af933d65da64bfb1a4dff1735"

clone_pin() {
    local url="$1"
    local sha="$2"
    local dest="$3"

    if [ -d "$dest/.git" ]; then
        echo ">>> $dest already exists — skipping (remove dir to re-fetch)"
        return
    fi

    echo ">>> Cloning $(basename "$dest") @ ${sha:0:12} ..."
    git init -q "$dest"
    git -C "$dest" remote add origin "$url"
    git -C "$dest" fetch --depth=1 origin "$sha" \
        || { echo ">>> ERROR: fetch failed: $dest"; exit 1; }
    git -C "$dest" checkout -q FETCH_HEAD
    echo ">>> $(basename "$dest") OK"
}

mkdir -p "$LAYERS_PIN_DIR"
cd "$LAYERS_PIN_DIR"

echo ">>> Fetching navonz_v1 pinned layers into ${LAYERS_PIN_DIR}"
clone_pin "$POKY_URL"           "$POKY_SHA"           "poky"
clone_pin "$META_OE_URL"        "$META_OE_SHA"        "meta-openembedded"
clone_pin "$META_ARM_URL"       "$META_ARM_SHA"       "meta-arm"
clone_pin "$META_ROCKCHIP_URL"  "$META_ROCKCHIP_SHA"  "meta-rockchip"

echo ">>> navonz_v1 layers ready (manifest: manifests/nanopc-t6-navonz_v1.xml)"
