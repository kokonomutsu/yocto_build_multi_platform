#!/bin/bash
# Fetch Yocto layers - supports both repo tool and git clone methods
set -e

BASE_DIR=/home/yocto
LAYERS_DIR=${BASE_DIR}/layers

# Check if using repo tool
if [ -f "${BASE_DIR}/.repo/manifest.xml" ] || [ -f ".repo/manifest.xml" ]; then
    echo ">>> Detected repo tool - using repo sync..."
    if [ -f "${BASE_DIR}/.repo/manifest.xml" ]; then
        cd ${BASE_DIR}
    else
        cd /home/picopiece/yocto_multi_platform
    fi
    repo sync -j16
    echo ">>> Layers fetched using repo tool!"
    exit 0
fi

# Fallback to git clone method
echo ">>> Using git clone method (repo tool not detected)..."
echo ">>> To use repo tool, run: scripts/fetch_layers_repo.sh"

mkdir -p $LAYERS_DIR
cd $LAYERS_DIR

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

