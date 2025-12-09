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
    
    # Find manifest file (check multiple locations)
    MANIFEST_PATH=""
    if [ -f "manifests/${MANIFEST}" ]; then
        MANIFEST_PATH="manifests/${MANIFEST}"
    elif [ -f "/home/picopiece/yocto_multi_platform/manifests/${MANIFEST}" ]; then
        MANIFEST_PATH="/home/picopiece/yocto_multi_platform/manifests/${MANIFEST}"
    elif [ -f "${BASE_DIR}/manifests/${MANIFEST}" ]; then
        MANIFEST_PATH="${BASE_DIR}/manifests/${MANIFEST}"
    fi
    
    if [ -n "${MANIFEST_PATH}" ] && [ -f "${MANIFEST_PATH}" ]; then
        echo ">>> Using manifest: ${MANIFEST_PATH}"
        # For local manifest, use file:// URL
        ABSOLUTE_MANIFEST_PATH=$(readlink -f ${MANIFEST_PATH} 2>/dev/null || echo ${MANIFEST_PATH})
        if [ -f "${ABSOLUTE_MANIFEST_PATH}" ]; then
            MANIFEST_URL="file://${ABSOLUTE_MANIFEST_PATH}"
            echo ">>> Using manifest URL: ${MANIFEST_URL}"
            repo init -u ${MANIFEST_URL} -m ${MANIFEST} \
                --repo-url=https://gerrit.googlesource.com/git-repo \
                --repo-branch=stable
        else
            echo ">>> ERROR: Cannot resolve absolute path for manifest: ${MANIFEST_PATH}"
            exit 1
        fi
    else
        echo ">>> ERROR: Manifest file ${MANIFEST} not found!"
        echo ">>> Available manifests:"
        ls -1 manifests/*.xml 2>/dev/null || \
        ls -1 /home/picopiece/yocto_multi_platform/manifests/*.xml 2>/dev/null || \
        echo "  No manifests found"
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

