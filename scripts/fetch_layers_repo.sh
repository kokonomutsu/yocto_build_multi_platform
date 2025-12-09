#!/bin/bash
# Fetch layers using repo tool
# This script replaces fetch_layers.sh when using repo tool

set -e

BASE_DIR=/home/yocto
MANIFEST=${1:-default.xml}

echo ">>> Fetching Yocto layers using repo tool..."
echo ">>> Manifest: ${MANIFEST}"

cd ${BASE_DIR}

# Check if repo is initialized
if [ ! -f ".repo/manifest.xml" ]; then
    echo ">>> Initializing repo..."
    
    # Determine repo URL (use local manifests if available)
    if [ -f "manifests/${MANIFEST}" ]; then
        echo ">>> Using local manifest: manifests/${MANIFEST}"
        repo init -m manifests/${MANIFEST} \
            --repo-url=https://git.codelinaro.org/clo/tools/repo.git \
            --repo-branch=qc-stable
    else
        echo ">>> ERROR: Manifest file manifests/${MANIFEST} not found!"
        echo ">>> Available manifests:"
        ls -1 manifests/*.xml 2>/dev/null || echo "  No manifests found"
        exit 1
    fi
else
    echo ">>> Repo already initialized"
    
    # Switch manifest if different
    CURRENT_MANIFEST=$(repo manifest | grep -oP 'manifest.*file="\K[^"]+' || echo "")
    if [ "${CURRENT_MANIFEST}" != "manifests/${MANIFEST}" ]; then
        echo ">>> Switching to manifest: ${MANIFEST}"
        repo init -m manifests/${MANIFEST}
    fi
fi

# Sync repositories
echo ">>> Syncing repositories (this may take a while)..."
repo sync -j16

echo ">>> All layers fetched successfully using repo tool!"
echo ">>> Layers are in: ${BASE_DIR}/layers/"

