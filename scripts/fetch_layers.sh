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

# Meta-amlogic (for S905x3) - optional, may require authentication
if [ ! -d "meta-amlogic" ]; then
    echo ">>> Cloning meta-amlogic..."
    git clone -b kirkstone --depth 1 https://github.com/BayLibre/meta-amlogic.git || echo ">>> WARNING: Failed to clone meta-amlogic (may require authentication or different URL)"
else
    echo ">>> meta-amlogic already exists, skipping..."
fi

echo ">>> All layers fetched successfully!"

