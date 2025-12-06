#!/bin/bash
set -e

echo ">>> Preparing host environment..."

# Create necessary directories
echo ">>> Creating directories..."
mkdir -p build-s905x3 build-rpi4 build-rpi0w layers downloads sstate-cache logs

# Set permissions
echo ">>> Setting permissions..."
chmod -R 755 build-s905x3 build-rpi4 build-rpi0w layers downloads sstate-cache logs

# RAM disk has been disabled for system stability
# Using default TMPDIR instead
echo ">>> Using default TMPDIR (RAM disk disabled for stability)"

# Check if SSD mount points exist (optional)
if [ -d "/mnt/ssd" ]; then
    echo ">>> SSD mount point found: /mnt/ssd"
    mkdir -p /mnt/ssd/downloads-s905x3 /mnt/ssd/downloads-rpi4
    mkdir -p /mnt/ssd/sstate-cache-s905x3 /mnt/ssd/sstate-cache-rpi4
    echo ">>> SSD directories created"
else
    echo ">>> WARNING: /mnt/ssd not found, using local directories"
fi

echo ">>> Host preparation complete!"

