# 🚀 RK3588 (NanoPC-T6) Build Configuration

## 📋 Hardware Overview

The NanoPC-T6 is a powerful ARM64 single board computer featuring:
- **SoC**: Rockchip RK3588
- **CPU**: 8-core processor (4x Cortex-A76 + 4x Cortex-A55)
- **RAM**: Up to 16GB LPDDR4X
- **Storage**: eMMC and microSD card support
- **Connectivity**: USB ports, HDMI output, Ethernet, WiFi, Bluetooth
- **GPU**: Mali-G610 MP4

## ⚙️ Build Configuration

### Machine
- **Machine Name**: `nanopc-t6`
- **Machine Config**: Provided by `meta-rockchip` layer
- **Distribution**: `poky`
- **Package Management**: `package_rpm`

### Required Layers
- `poky/meta`: Core Yocto functionality
- `poky/meta-poky`: Poky distribution
- `poky/meta-yocto-bsp`: Board support packages
- `meta-rockchip`: Rockchip SoC support (RK3588)
- `meta-arm/meta-arm`: ARM architecture support
- `meta-arm/meta-arm-toolchain`: ARM toolchain
- `meta-openembedded/meta-oe`: OpenEmbedded core
- `meta-openembedded/meta-python`: Python support
- `meta-openembedded/meta-multimedia`: Multimedia support

## 🚀 Quick Start

RK3588 hỗ trợ hai **profile** build:

| Profile | Layers | Build dir | Mô tả |
|---------|--------|-----------|-------|
| `developer` | `layers/` (kirkstone) + custom `products/rk3588` | `build-rk3588/` | Custom, linh hoạt |
| `navonz_v1` | `layers-pin/` (commit pin đã verify) | `build-rk3588-navonz_v1/` | Snapshot gốc yocto-nanopc-t6 |

### Profile: developer (custom kirkstone)

#### 1. Fetch Layers
```bash
./scripts/fetch_layers.sh
```

#### 2. Setup + Build
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c \
  "scripts/setup_env.sh rk3588 developer && \
   scripts/build.sh rk3588 developer core-image-minimal"
```

### Profile: navonz_v1 (pinned snapshot)

#### 1. Fetch pinned layers (lần đầu / khi cần refresh)
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c \
  "scripts/fetch_layers_pin.sh"
```

#### 2. Setup + Build
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c \
  "scripts/setup_env.sh rk3588 navonz_v1 && \
   scripts/build.sh rk3588 navonz_v1 core-image-minimal"
```

Hoặc dùng wrapper:
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c \
  "scripts/build_rk3588.sh navonz_v1 core-image-minimal"
```

Manifest pin: `manifests/nanopc-t6-navonz_v1.xml`

## 📦 Available Images

You can build different image types:

```bash
# Minimal image (fastest build, basic functionality)
scripts/build.sh rk3588 developer core-image-minimal

# Base image with more packages
scripts/build.sh rk3588 developer core-image-base

# Image with development tools
scripts/build.sh rk3588 developer core-image-full-cmdline

# Image with X11 support
scripts/build.sh rk3588 developer core-image-x11
```

## 📁 Build Output

After a successful build, images will be located in:
```
build-rk3588/tmp/deploy/images/nanopc-t6/              # developer
build-rk3588-navonz_v1/tmp/deploy/images/nanopc-t6/    # navonz_v1
```

Key files include:
- `*.wic`: Complete disk image for SD card/eMMC
- `*.wic.xz`: Compressed disk image
- `Image`: Linux kernel (ARM64)
- `*.dtb`: Device tree blob
- `*rootfs.tar.xz`: Root filesystem archive

## 💾 Flashing to Device

### Using Balena Etcher (Recommended)
1. Install Balena Etcher
2. Select the `.wic` or `.wic.xz` image file
3. Select your SD card or USB drive
4. Flash the image

### Using dd (Linux/macOS)
```bash
# Decompress if needed
xz -d your-image.wic.xz

# Flash to SD card (replace /dev/sdX with your device)
sudo dd if=your-image.wic of=/dev/sdX bs=4M status=progress
sync
```

## ⚙️ Configuration Options

### Machine-Specific Features
The NanoPC-T6 supports these optional features:
- **U-Boot Environment**: Add `rk-u-boot-env` to `MACHINE_FEATURES`
- **Hardware Video Decoding**: Enabled by default for GStreamer
- **A/B Updates with RAUC**: Available for system updates

### Customization Examples

#### Enable Development Tools
Add to `conf/local.conf`:
```bash
EXTRA_IMAGE_FEATURES += "debug-tweaks tools-sdk tools-debug"
```

#### Add Custom Packages
```bash
IMAGE_INSTALL:append = " your-package-name"
```

#### Enable systemd
```bash
INIT_MANAGER = "systemd"
```

## 🛠️ Troubleshooting

### Build Issues

#### Missing meta-rockchip layer
```bash
# Ensure layers are fetched
./scripts/fetch_layers.sh

# Verify meta-rockchip exists
ls -la layers/meta-rockchip
```

#### Machine not found
The `nanopc-t6` machine config should be in:
```
layers/meta-rockchip/conf/machine/nanopc-t6.conf
```

If missing, check that you're using the correct branch (kirkstone).

#### Build fails with ARM toolchain errors
Ensure `meta-arm/meta-arm-toolchain` is in `bblayers.conf`.

## 📚 References

- [meta-rockchip Documentation](https://git.yoctoproject.org/git/meta-rockchip)
- [NanoPC-T6 Wiki](https://wiki.friendlyelec.com/wiki/index.php/NanoPC-T6)
- [Rockchip RK3588 Documentation](https://www.rock-chips.com/a/en/products/RK35_Series/)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)

## 🔍 Notes

- Build time: RK3588 builds typically take longer than RPi4 due to complexity
- Disk space: Ensure at least 100GB free space
- Memory: 16GB+ RAM recommended for faster builds
- The `nanopc-t6` machine config is provided by `meta-rockchip` layer
- No custom machine config needed (unlike S905x3)

