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
    
    # Repo tool approach: Use local_manifests (standard way for local manifests)
    # Step 1: Initialize repo with a dummy/minimal manifest URL
    # We'll override with local_manifests
    echo ">>> Initializing repo tool..."
    
    # Create a minimal default.xml first (repo init requires -u)
    # Use a dummy git repo or create minimal manifest repo
    # Actually, simpler: init without -u, then use local_manifests
    
    # Alternative: Create a git repo for manifest temporarily
    # Resolve absolute path first
    ABSOLUTE_MANIFEST_PATH=$(readlink -f ${MANIFEST_PATH} 2>/dev/null || realpath ${MANIFEST_PATH} 2>/dev/null || echo ${MANIFEST_PATH})
    if [ ! -f "${ABSOLUTE_MANIFEST_PATH}" ]; then
        ABSOLUTE_MANIFEST_PATH=${MANIFEST_PATH}
    fi
    
    TEMP_MANIFEST_REPO=$(mktemp -d)
    cd ${TEMP_MANIFEST_REPO}
    git init -q
    # Set git config for commit (required)
    git config user.name "Repo Tool" || true
    git config user.email "repo@localhost" || true
    cp ${ABSOLUTE_MANIFEST_PATH} default.xml
    git add default.xml
    git commit -q -m "Initial manifest"
    MANIFEST_REPO_URL="file://${TEMP_MANIFEST_REPO}"
    
    cd ${BASE_DIR}
    echo ">>> Initializing with temporary manifest repository..."
    repo init -u ${MANIFEST_REPO_URL} -m default.xml \
        --repo-url=https://gerrit.googlesource.com/git-repo \
        --repo-branch=stable
    
    # Cleanup temp repo
    rm -rf ${TEMP_MANIFEST_REPO}
    
    echo ">>> Repo initialized successfully!"
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

