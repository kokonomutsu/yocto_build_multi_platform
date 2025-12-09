#!/bin/bash
set -e

BASE_DIR=/home/yocto/layers
mkdir -p $BASE_DIR
cd $BASE_DIR

echo ">>> Fetching Yocto layers..."

# Poky (core layer)
if [ ! -d "poky" ]; then
    echo ">>> Cloning poky..."
    git clone -b kirkstone --depth 1 https://git.yoctoproject.org/git/poky
else
    echo ">>> poky already exists, skipping..."
fi

# Meta-openembedded
if [ ! -d "meta-openembedded" ]; then
    echo ">>> Cloning meta-openembedded..."
    git clone -b kirkstone --depth 1 https://github.com/openembedded/meta-openembedded.git
else
    echo ">>> meta-openembedded already exists, skipping..."
fi

# Meta-raspberrypi (for RPi4)
if [ ! -d "meta-raspberrypi" ]; then
    echo ">>> Cloning meta-raspberrypi..."
    git clone -b kirkstone --depth 1 https://github.com/agherzan/meta-raspberrypi.git
else
    echo ">>> meta-raspberrypi already exists, skipping..."
fi

# Meta-meson (for S905x3 - G12A/G12B/SM1 support)
if [ ! -d "meta-meson" ]; then
    echo ">>> Cloning meta-meson..."
    git clone -b kirkstone --depth 1 https://github.com/superna9999/meta-meson.git || echo ">>> WARNING: Failed to clone meta-meson"
else
    echo ">>> meta-meson already exists, skipping..."
fi

# Meta-rockchip (for RK3588/NanoPC-T6)
if [ ! -d "meta-rockchip" ]; then
    echo ">>> Cloning meta-rockchip..."
    git clone -b kirkstone --depth 1 https://git.yoctoproject.org/git/meta-rockchip || echo ">>> WARNING: Failed to clone meta-rockchip"
else
    echo ">>> meta-rockchip already exists, skipping..."
fi

# Meta-arm (ARM architecture support - recommended for RK3588)
if [ ! -d "meta-arm" ]; then
    echo ">>> Cloning meta-arm..."
    git clone -b kirkstone --depth 1 https://git.yoctoproject.org/git/meta-arm || echo ">>> WARNING: Failed to clone meta-arm"
else
    echo ">>> meta-arm already exists, skipping..."
fi

echo ">>> All layers fetched successfully!"

