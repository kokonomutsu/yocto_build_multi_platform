# 📚 Tài liệu tham khảo: Yocto NanoPC-T6 Project

Tài liệu này tổng hợp thông tin từ project `yocto-nanopc-t6-master` để tham khảo khi tích hợp RK3588 vào `yocto_multi_platform`.

## 📋 Tổng quan

### Hardware: NanoPC-T6
- **SoC**: Rockchip RK3588
- **CPU**: 8-core (4x Cortex-A76 + 4x Cortex-A55)
- **RAM**: Up to 16GB LPDDR4X
- **Storage**: eMMC và microSD card
- **Connectivity**: USB, HDMI, Ethernet, WiFi, Bluetooth
- **GPU**: Mali-G610 MP4

### Project Structure
Project gốc sử dụng `repo` tool để quản lý multiple repositories thông qua manifest files.

## 📦 Manifest Files

### 1. `default.xml` (Manifest chính)
**Mục đích**: Manifest chính cho build production với các revisions cố định.

**Repositories**:
```xml
- poky: revision="1dec53b350d7d2edcc880f640b1cb2fd31ff7f0b" (upstream="master")
- meta-openembedded: revision="fd6a9a2b30fab61c3761b42110b37512756f3525" (upstream="master")
- meta-rockchip: revision="4fdc16878efb6e1af933d65da64bfb1a4dff1735" (upstream="master")
- meta-arm: revision="a3a2c49b2149606f314b2ee0aeba7d6becd12545" (upstream="master")
- meta-web-kiosk: revision="7bf1e5b2cffb58d521353b00a1a3049c520875ed" (upstream="master")
- thangbk/yocto-nanopc-t6: revision="meta-marine" (custom layer)
```

**Đặc điểm**:
- Sử dụng revisions cụ thể (snapshot) để đảm bảo reproducibility
- Copy file `meta-marine/source-build-marine-image.sh` từ custom repo
- Tất cả đều từ upstream "master" nhưng pin vào revisions cụ thể

### 2. `default_mainline.xml` (Manifest mainline)
**Mục đích**: Manifest cho mainline kernel builds, sử dụng latest từ master branches.

**Repositories**:
```xml
- poky: revision="master"
- meta-openembedded: revision="master"
- meta-rockchip: revision="master"
- meta-arm: revision="master"
- meta-web-kiosk: revision="master"
```

**Đặc điểm**:
- Không pin revisions (luôn lấy latest)
- Không có custom layer `meta-marine`
- Phù hợp cho development/testing

### 3. `nanopc-t6-2025-08-16.xml` (Snapshot manifest)
**Mục đích**: Snapshot cụ thể từ ngày 16/08/2025, chỉ có core layers.

**Repositories**:
```xml
- poky: revision="1dec53b350d7d2edcc880f640b1cb2fd31ff7f0b"
- meta-openembedded: revision="fd6a9a2b30fab61c3761b42110b37512756f3525"
- meta-rockchip: revision="4fdc16878efb6e1af933d65da64bfb1a4dff1735"
- meta-arm: revision="a3a2c49b2149606f314b2ee0aeba7d6becd12545"
- meta-web-kiosk: revision="7bf1e5b2cffb58d521353b00a1a3049c520875ed"
```

**Đặc điểm**:
- Không có custom layer
- Minimal setup cho snapshot testing

## 🏗️ Build Configuration

### Layers được sử dụng:
1. **poky/meta**: Core OpenEmbedded functionality
2. **poky/meta-poky**: Poky distribution configuration
3. **poky/meta-yocto-bsp**: Board support packages
4. **meta-rockchip**: Rockchip SoC support (RK3588)
5. **meta-arm/meta-arm**: ARM architecture support
6. **meta-arm/meta-arm-toolchain**: ARM toolchain
7. **meta-openembedded/meta-oe**: OpenEmbedded core
8. **meta-openembedded/meta-python**: Python support
9. **meta-openembedded/meta-multimedia**: Multimedia support
10. **meta-marine**: Custom layer (trong project gốc)
11. **meta-web-kiosk**: Browser layer (optional)

### Machine Configuration:
- **Machine**: `nanopc-t6`
- **Distribution**: `poky`
- **Package Management**: `package_rpm`
- **Kernel**: `linux-yocto` (from rockchip-defaults.inc)
- **U-Boot**: Rockchip-specific patches

### Build Script:
Project gốc sử dụng `source-build-marine-image.sh` để:
- Copy config từ `meta-marine/build-conf` → `build-marine/conf`
- Setup build environment
- Initialize BitBake

## 🐳 Docker Setup

### Docker Image:
- **Base Image**: `thangbk/build-os:latest`
- **Container Name**: `ivan-local`
- **User**: `1000:1000` (maps host user)
- **Entrypoint**: `while true; do sleep 30; done` (persistent container)

### Volume Mounts:
```yaml
- $HOME/workspace → /home/user/workspace
- $HOME/Documents → /home/user/Documents
- /etc/localtime → /etc/localtime
```

### Workflow:
1. Start container: `docker-compose up -d`
2. Enter container: `docker exec -it ivan-local bash`
3. Work inside container, files persist on host

## 🚀 Build Process

### 1. Initialize Repository:
```bash
repo init --depth=1 -u git@github.com:thangbk/yocto-nanopc-t6.git \
    -m default.xml \
    --repo-url=https://git.codelinaro.org/clo/tools/repo.git \
    --repo-branch=qc-stable
```

### 2. Sync Repositories:
```bash
repo sync -j16
```

### 3. Setup Build Environment:
```bash
source source-build-marine-image.sh
```

### 4. Build:
```bash
bitbake core-image-minimal
```

## 📦 Available Images

- `core-image-minimal`: Minimal image (fastest build)
- `core-image-base`: Base image with more packages
- `core-image-full-cmdline`: Image with development tools
- `core-image-x11`: Image with X11 support
- `core-image-sato`: Image with Sato desktop

## 📁 Build Output

Images được tạo tại:
```
tmp/deploy/images/nanopc-t6/
```

Key files:
- `*.wic`: Complete disk image for SD card/eMMC
- `*.wic.xz`: Compressed disk image
- `Image` hoặc `zImage`: Linux kernel
- `*.dtb`: Device tree blob
- `*rootfs.tar.xz`: Root filesystem archive

## ⚙️ Configuration Details

### Machine Features:
- U-Boot Environment: `rk-u-boot-env` (optional)
- Hardware Video Decoding: Enabled by default
- A/B Updates with RAUC: Available

### Customization Examples:

#### Enable Development Tools:
```bash
EXTRA_IMAGE_FEATURES += "debug-tweaks tools-sdk tools-debug"
```

#### Add Custom Packages:
```bash
IMAGE_INSTALL:append = " your-package-name"
```

#### Enable systemd:
```bash
INIT_MANAGER = "systemd"
```

### Build Optimization:
```bash
BB_NUMBER_THREADS = "8"    # Number of CPU cores
PARALLEL_MAKE = "-j 8"     # Make jobs
SSTATE_DIR = "/path/to/shared/sstate-cache"
DL_DIR = "/path/to/shared/downloads"
```

## 🔧 Hardware Support (từ meta-rockchip)

- **Boot**: U-Boot bootloader with Rockchip-specific patches
- **Kernel**: Linux kernel with RK3588 device drivers
- **Graphics**: Mali GPU support and display drivers
- **Multimedia**: Hardware video acceleration (VPU)
- **Connectivity**: USB, Ethernet, WiFi, Bluetooth

## 💾 Flashing to Device

### Using Balena Etcher:
1. Select `.wic` or `.wic.xz` image
2. Select SD card/USB drive
3. Flash

### Using dd:
```bash
xz -d your-image.wic.xz
sudo dd if=your-image.wic of=/dev/sdX bs=4M status=progress
sync
```

## 🛠️ Troubleshooting

### Common Issues:

1. **Python Version**: 
   - Project gốc yêu cầu Python 2.7
   - `sudo update-alternatives --config python`

2. **Disk Space**:
   - Build directory: 50GB+
   - Downloads: 20GB+
   - Shared state: 30GB+

3. **Repo Sync Failures**:
   - Retry with verbose: `repo sync -v -j4`
   - Force sync: `repo sync --force-sync`

4. **UTF-8 Locale Errors**:
   ```bash
   export LANG=en_US.UTF-8
   export LC_ALL=en_US.UTF-8
   ```

## 📊 So sánh với yocto_multi_platform

| Aspect | yocto-nanopc-t6 | yocto_multi_platform |
|--------|----------------|---------------------|
| **Repo Management** | `repo` tool (manifest) | Git clone trực tiếp |
| **Layers Location** | Trong workspace | `/home/yocto/layers/` |
| **Build Config** | `meta-marine/build-conf` | `products/<platform>/conf/` |
| **Docker Setup** | Custom image `thangbk/build-os` | Custom Dockerfile |
| **Machine Config** | Trong meta-rockchip | Custom layer `products/rk3588` |
| **Build Script** | `source-build-marine-image.sh` | `scripts/setup_env.sh` + `scripts/build.sh` |
| **Yocto Version** | Master (pinned revisions) | Kirkstone (stable) |

## 🔑 Key Takeaways

1. **Revisions**: Project gốc pin vào revisions cụ thể để đảm bảo reproducibility
2. **Custom Layer**: Project gốc có `meta-marine` custom layer với build configs
3. **Docker**: Sử dụng persistent container với entrypoint keep-alive
4. **Repo Tool**: Quản lý multiple repositories thông qua manifest files
5. **Machine Config**: `nanopc-t6` machine config có trong meta-rockchip (master branch)

## 📚 References

- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [meta-rockchip Layer](https://git.yoctoproject.org/git/meta-rockchip/)
- [NanoPC-T6 Hardware Documentation](https://wiki.friendlyelec.com/wiki/index.php/NanoPC-T6)
- [Rockchip RK3588 Documentation](https://www.rock-chips.com/a/en/products/RK35_Series/)

## 💡 Notes cho yocto_multi_platform

1. **Machine Config**: 
   - Project gốc có `nanopc-t6` trong meta-rockchip master
   - yocto_multi_platform dùng kirkstone → cần custom machine config
   - ✅ Đã tạo: `products/rk3588/conf/machine/nanopc-t6.conf`

2. **Kernel Provider**:
   - Project gốc dùng `linux-yocto` từ rockchip-defaults.inc
   - ✅ Đã tạo bbappend: `products/rk3588/recipes-kernel/linux/linux-yocto_%.bbappend`

3. **Layers**:
   - Project gốc có `meta-marine` custom layer
   - yocto_multi_platform dùng `products/rk3588` custom layer
   - ✅ Tương đương về chức năng

4. **Build Process**:
   - Project gốc: `repo sync` → `source-build-marine-image.sh` → `bitbake`
   - yocto_multi_platform: `fetch_layers.sh` → `setup_env.sh` → `build.sh`
   - ✅ Tương đương về workflow

