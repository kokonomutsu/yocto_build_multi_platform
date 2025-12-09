#!/bin/bash
# Initialize repo tool for yocto_multi_platform
# This script sets up repo tool for the first time

set -e

BASE_DIR=/home/yocto
MANIFEST=${1:-default.xml}

echo ">>> Initializing repo tool..."
echo ">>> Manifest: ${MANIFEST}"

cd ${BASE_DIR}

# Check if repo tool is installed
if ! command -v repo &> /dev/null; then
    echo ">>> ERROR: repo tool is not installed!"
    echo ">>> Please install repo tool first:"
    echo ">>>   mkdir -p ~/bin"
    echo ">>>   curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo"
    echo ">>>   chmod a+x ~/bin/repo"
    echo ">>>   export PATH=~/bin:\$PATH"
    exit 1
fi

# Check if already initialized
if [ -f ".repo/manifest.xml" ]; then
    echo ">>> Repo already initialized"
    echo ">>> Current manifest: $(repo manifest | grep -oP 'manifest.*file="\K[^"]+' || echo 'unknown')"
    read -p ">>> Re-initialize? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ">>> Aborted"
        exit 0
    fi
    rm -rf .repo
fi

# Find manifest file (check multiple locations)
MANIFEST_PATH=""
if [ -f "manifests/${MANIFEST}" ]; then
    MANIFEST_PATH="manifests/${MANIFEST}"
elif [ -f "/home/picopiece/yocto_multi_platform/manifests/${MANIFEST}" ]; then
    MANIFEST_PATH="/home/picopiece/yocto_multi_platform/manifests/${MANIFEST}"
elif [ -f "${BASE_DIR}/manifests/${MANIFEST}" ]; then
    MANIFEST_PATH="${BASE_DIR}/manifests/${MANIFEST}"
fi

# Initialize repo
if [ -n "${MANIFEST_PATH}" ] && [ -f "${MANIFEST_PATH}" ]; then
    echo ">>> Initializing with manifest: ${MANIFEST_PATH}"
    # For local manifest, we need to use -u with file:// URL or absolute path
    # Use file:// protocol for local manifest
    ABSOLUTE_MANIFEST_PATH=$(readlink -f ${MANIFEST_PATH} 2>/dev/null || echo ${MANIFEST_PATH})
    if [ -f "${ABSOLUTE_MANIFEST_PATH}" ]; then
        # Use file:// URL for local manifest
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
    echo ">>> Searched in:"
    echo ">>>   - manifests/${MANIFEST}"
    echo ">>>   - /home/picopiece/yocto_multi_platform/manifests/${MANIFEST}"
    echo ">>>   - ${BASE_DIR}/manifests/${MANIFEST}"
    echo ">>> Available manifests:"
    ls -1 manifests/*.xml 2>/dev/null || \
    ls -1 /home/picopiece/yocto_multi_platform/manifests/*.xml 2>/dev/null || \
    echo "  No manifests found"
    exit 1
fi

echo ">>> Repo initialized successfully!"
echo ">>> Run 'repo sync' or 'scripts/fetch_layers.sh' to sync repositories"

