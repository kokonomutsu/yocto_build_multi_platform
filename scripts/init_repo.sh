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

# Initialize repo
if [ -f "manifests/${MANIFEST}" ]; then
    echo ">>> Initializing with local manifest: manifests/${MANIFEST}"
    repo init -m manifests/${MANIFEST} \
        --repo-url=https://git.codelinaro.org/clo/tools/repo.git \
        --repo-branch=qc-stable
else
    echo ">>> ERROR: Manifest file manifests/${MANIFEST} not found!"
    echo ">>> Available manifests:"
    ls -1 manifests/*.xml 2>/dev/null || echo "  No manifests found"
    exit 1
fi

echo ">>> Repo initialized successfully!"
echo ">>> Run 'repo sync' or 'scripts/fetch_layers.sh' to sync repositories"

