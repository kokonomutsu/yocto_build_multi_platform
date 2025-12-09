# 🚀 Kế hoạch tích hợp RK3588 (NanoPC-T6) vào yocto_multi_platform

## 📋 Phân tích thư mục yocto-nanopc-t6-master

### Cấu trúc hiện tại của yocto-nanopc-t6-master:

1. **Quản lý repositories**: Sử dụng `repo` tool với manifest files (`.xml`)
   - `default.xml`: Manifest chính với các layers cố định
   - `default_mainline.xml`: Manifest cho mainline kernel
   - `nanopc-t6-2025-08-16.xml`: Manifest snapshot cụ thể

2. **Layers được sử dụng**:
   - `poky`: Core Yocto (revision: 1dec53b350d7d2edcc880f640b1cb2fd31ff7f0b)
   - `meta-openembedded`: Extended functionality (revision: fd6a9a2b30fab61c3761b42110b37512756f3525)
   - `meta-rockchip`: Rockchip SoC support cho RK3588 (revision: 4fdc16878efb6e1af933d65da64bfb1a4dff1735)
   - `meta-arm`: ARM architecture support (revision: a3a2c49b2149606f314b2ee0aeba7d6becd12545)
   - `meta-web-kiosk`: Optional browser layer (revision: 7bf1e5b2cffb58d521353b00a1a3049c520875ed)

3. **Machine Configuration**:
   - Machine name: `nanopc-t6`
   - Machine config có sẵn trong `meta-rockchip/conf/machine/nanopc-t6.conf`
   - Distribution: `poky`
   - Package management: `package_rpm`

4. **Build Script**:
   - Sử dụng `source-build-marine-image.sh` để setup environment
   - Script này copy config từ `meta-marine/build-conf` → `build-marine/conf`

### So sánh với yocto_multi_platform:

| Aspect | yocto-nanopc-t6 | yocto_multi_platform |
|--------|----------------|---------------------|
| Repo Management | `repo` tool (manifest) | Git clone trực tiếp |
| Layers Location | Trong workspace | `/home/yocto/layers/` |
| Build Config | `meta-marine/build-conf` | `products/<platform>/conf/` |
| Docker Setup | Custom image `thangbk/build-os` | Custom Dockerfile |
| Machine Config | Trong meta-rockchip | Có thể override trong custom layer |

## 🎯 Các bước tích hợp

### Bước 1: Thêm các layers cần thiết vào fetch_layers.sh

**File**: `scripts/fetch_layers.sh`

Cần thêm:
- `meta-rockchip`: Layer chính cho RK3588 support
- `meta-arm`: ARM architecture support (optional nhưng recommended)

**Chi tiết**:
```bash
# Meta-rockchip (for RK3588/NanoPC-T6)
if [ ! -d "meta-rockchip" ]; then
    echo ">>> Cloning meta-rockchip..."
    git clone -b kirkstone --depth 1 https://git.yoctoproject.org/git/meta-rockchip
else
    echo ">>> meta-rockchip already exists, skipping..."
fi

# Meta-arm (ARM architecture support)
if [ ! -d "meta-arm" ]; then
    echo ">>> Cloning meta-arm..."
    git clone -b kirkstone --depth 1 https://git.yoctoproject.org/git/meta-arm
else
    echo ">>> meta-arm already exists, skipping..."
fi
```

### Bước 2: Tạo cấu trúc thư mục cho RK3588

**Tạo**: `products/rk3588/conf/`

Cần tạo:
- `products/rk3588/conf/local.conf`
- `products/rk3588/conf/bblayers.conf`
- `products/rk3588/README.md` (optional documentation)

### Bước 3: Cấu hình bblayers.conf cho RK3588

**File**: `products/rk3588/conf/bblayers.conf`

Cần include:
- `poky/meta`
- `poky/meta-poky`
- `poky/meta-yocto-bsp`
- `meta-openembedded/meta-oe`
- `meta-openembedded/meta-python`
- `meta-openembedded/meta-multimedia`
- `meta-rockchip` (mới)
- `meta-arm/meta-arm` (mới, optional)
- `meta-arm/meta-arm-toolchain` (mới, optional)

### Bước 4: Cấu hình local.conf cho RK3588

**File**: `products/rk3588/conf/local.conf`

Key settings:
- `MACHINE ??= "nanopc-t6"`
- `DISTRO ?= "poky"`
- `PACKAGE_CLASSES ?= "package_rpm"` (giống nanopc-t6 project)
- `BB_NUMBER_THREADS ?= "20"` (giống các platform khác)
- `PARALLEL_MAKE ?= "-j20"`
- `DL_DIR` và `SSTATE_DIR` (giống các platform khác)

### Bước 5: Cập nhật các scripts

**Files cần cập nhật**:
1. `scripts/setup_env.sh`: Thêm `rk3588` vào usage message
2. `scripts/build.sh`: Thêm `rk3588` vào usage message
3. `scripts/host_prepare.sh`: Tạo `build-rk3588` directory
4. `scripts/nuke-and-rebuild.sh`: Thêm `rk3588` support
5. `scripts/rebuild-image.sh`: Thêm `rk3588` support
6. `scripts/fetch_missing_sources.sh`: Thêm `rk3588` support

### Bước 6: Cập nhật docker-compose.yml

**File**: `docker-compose.yml`

Thêm volume mount:
```yaml
- ./build-rk3588:/home/yocto/build-rk3588
```

### Bước 7: Kiểm tra machine config

**Kiểm tra**: `meta-rockchip/conf/machine/nanopc-t6.conf` có tồn tại không

Nếu không có, cần tạo custom layer hoặc override machine config.

### Bước 8: Tạo README cho RK3588

**File**: `products/rk3588/README.md`

Documentation về:
- Hardware specs
- Build instructions
- Image output locations
- Flashing instructions

## 📝 Checklist tích hợp

- [ ] Bước 1: Cập nhật `scripts/fetch_layers.sh` với meta-rockchip và meta-arm
- [ ] Bước 2: Tạo `products/rk3588/conf/` directory
- [ ] Bước 3: Tạo `products/rk3588/conf/bblayers.conf`
- [ ] Bước 4: Tạo `products/rk3588/conf/local.conf`
- [ ] Bước 5: Cập nhật tất cả scripts để hỗ trợ `rk3588`
- [ ] Bước 6: Cập nhật `docker-compose.yml` với volume mount
- [ ] Bước 7: Kiểm tra machine config `nanopc-t6` trong meta-rockchip
- [ ] Bước 8: Tạo `products/rk3588/README.md`
- [ ] Bước 9: Test fetch layers
- [ ] Bước 10: Test build environment setup
- [ ] Bước 11: Test build core-image-minimal

## 🔍 Lưu ý quan trọng

1. **Yocto Version**: 
   - yocto-nanopc-t6 sử dụng các revisions cụ thể (có thể là kirkstone hoặc scarthgap)
   - yocto_multi_platform đang dùng `kirkstone`
   - Cần đảm bảo `meta-rockchip` và `meta-arm` tương thích với `kirkstone`

2. **Machine Name**:
   - Machine name: `nanopc-t6` (có sẵn trong meta-rockchip)
   - Không cần tạo custom machine config như S905x3

3. **Package Management**:
   - nanopc-t6 project dùng `package_rpm`
   - Có thể giữ nguyên hoặc đổi sang `package_deb` (tùy preference)

4. **Optional Layers**:
   - `meta-arm`: Recommended cho ARM64 builds
   - `meta-web-kiosk`: Optional, chỉ cần nếu build browser

5. **Build Time**:
   - RK3588 build sẽ lâu hơn RPi4 do phức tạp hơn
   - Cần đảm bảo đủ disk space (100GB+)

## 🚀 Quick Start sau khi tích hợp

```bash
# 1. Fetch layers (bao gồm meta-rockchip và meta-arm)
./scripts/fetch_layers.sh

# 2. Setup environment
HOST_UID=1000 HOST_GID=1000 docker-compose run --rm yocto bash -c "scripts/setup_env.sh rk3588 developer"

# 3. Build image
HOST_UID=1000 HOST_GID=1000 docker-compose run --rm yocto bash -c "scripts/build.sh rk3588 developer core-image-minimal"
```

## 📚 References

- [meta-rockchip Documentation](https://git.yoctoproject.org/git/meta-rockchip)
- [NanoPC-T6 Wiki](https://wiki.friendlyelec.com/wiki/index.php/NanoPC-T6)
- [Rockchip RK3588 Documentation](https://www.rock-chips.com/a/en/products/RK35_Series/)

