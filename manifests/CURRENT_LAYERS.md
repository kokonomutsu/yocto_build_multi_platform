# Current Layers Documentation

## Layers currently used in yocto_multi_platform

### Core Layers
- **poky**: kirkstone branch
  - Source: https://git.yoctoproject.org/git/poky
  - Path: layers/poky

- **meta-openembedded**: kirkstone branch
  - Source: https://github.com/openembedded/meta-openembedded.git
  - Path: layers/meta-openembedded

### Platform-Specific Layers
- **meta-raspberrypi**: kirkstone branch
  - Source: https://github.com/agherzan/meta-raspberrypi.git
  - Path: layers/meta-raspberrypi
  - Used for: rpi4, rpi0w

- **meta-meson**: kirkstone branch
  - Source: https://github.com/superna9999/meta-meson.git
  - Path: layers/meta-meson
  - Used for: s905x3

- **meta-rockchip**: kirkstone branch
  - Source: https://git.yoctoproject.org/git/meta-rockchip
  - Path: layers/meta-rockchip
  - Used for: rk3588

- **meta-arm**: kirkstone branch
  - Source: https://git.yoctoproject.org/git/meta-arm
  - Path: layers/meta-arm
  - Used for: rk3588

## Platforms
- s905x3 (Amlogic)
- rpi4 (Raspberry Pi 4)
- rpi0w (Raspberry Pi Zero W)
- rk3588 (NanoPC-T6)

## Custom Layers
- products/s905x3 (custom layer for S905x3)
- products/rk3588 (custom layer for RK3588)
