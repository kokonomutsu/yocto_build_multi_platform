# Raspberry Pi Zero W Build Configuration

## Machine
- **MACHINE**: `raspberrypi0-wifi`
- **Architecture**: ARM 32-bit (arm1176jzfshf)
- **Board**: Raspberry Pi Zero W

## Features
- WiFi support (BCM43430)
- Bluetooth support
- Serial console: 115200;ttyS0

## Build
```bash
# Setup environment
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh rpi0w developer"

# Build image
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh rpi0w developer core-image-minimal"
```

Or use quick build:
```bash
./scripts/quick_build.sh rpi0w core-image-minimal
```

## Output
Images will be in: `build-rpi0w/tmp/deploy/images/raspberrypi0-wifi/`
