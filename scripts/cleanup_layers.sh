#!/bin/bash
# Cleanup layers with invalid git state for repo tool migration
# This script removes .git directories from layers that were cloned with git clone

set -e

BASE_DIR=/home/yocto
LAYERS_DIR=${BASE_DIR}/layers

echo ">>> Cleaning up layers for repo tool migration..."

if [ ! -d "${LAYERS_DIR}" ]; then
    echo ">>> No layers directory found, nothing to clean"
    exit 0
fi

# Backup warning
echo ">>> WARNING: This will remove .git directories from existing layers"
echo ">>> Layers will be re-cloned by repo tool"
read -p ">>> Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ">>> Aborted"
    exit 0
fi

# Remove .git directories from layers
for layer_dir in ${LAYERS_DIR}/*/; do
    if [ -d "${layer_dir}/.git" ]; then
        layer_name=$(basename ${layer_dir})
        echo ">>> Removing .git from: ${layer_name}"
        rm -rf "${layer_dir}/.git"
    fi
done

# Also remove .repo if exists
if [ -d "${LAYERS_DIR}/.repo" ]; then
    echo ">>> Removing .repo directory"
    rm -rf "${LAYERS_DIR}/.repo"
fi

if [ -d "${BASE_DIR}/.repo" ]; then
    echo ">>> Removing .repo directory from base"
    rm -rf "${BASE_DIR}/.repo"
fi

echo ">>> Cleanup complete!"
echo ">>> You can now run: scripts/init_repo.sh"

