#!/bin/bash
set -e

echo ">>> Preparing host environment..."

# Create necessary directories
echo ">>> Creating directories..."
mkdir -p build-s905x3 build-rpi4 build-rpi0w build-rk3588 build-rk3588-navonz_v1 \
    layers layers-pin downloads sstate-cache logs

# Set permissions
echo ">>> Setting permissions..."
chmod -R 755 build-s905x3 build-rpi4 build-rpi0w build-rk3588 build-rk3588-navonz_v1 \
    layers layers-pin downloads sstate-cache logs

# RAM disk has been disabled for system stability
# Using default TMPDIR instead
echo ">>> Using default TMPDIR (RAM disk disabled for stability)"

# Check if SSD mount points exist (optional)
if [ -d "/mnt/ssd" ]; then
    echo ">>> SSD mount point found: /mnt/ssd"
    # Try to create directories, but don't fail if permission denied
    mkdir -p /mnt/ssd/downloads-s905x3 /mnt/ssd/downloads-rpi4 /mnt/ssd/downloads-rk3588 2>/dev/null || echo ">>> WARNING: Cannot create SSD downloads directories (permission denied, using local directories)"
    mkdir -p /mnt/ssd/sstate-cache-s905x3 /mnt/ssd/sstate-cache-rpi4 /mnt/ssd/sstate-cache-rk3588 2>/dev/null || echo ">>> WARNING: Cannot create SSD sstate-cache directories (permission denied, using local directories)"
    if [ -w "/mnt/ssd" ]; then
        echo ">>> SSD directories created"
    else
        echo ">>> WARNING: /mnt/ssd is not writable, using local directories"
    fi
else
    echo ">>> WARNING: /mnt/ssd not found, using local directories"
fi

echo ">>> Host preparation complete!"

