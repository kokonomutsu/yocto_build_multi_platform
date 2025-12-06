# 🚀 Hướng dẫn Build Yocto cho Người Mới

## 📋 Mục tiêu

Hướng dẫn từng bước để build Yocto image cho Raspberry Pi 4 hoặc S905x3 từ đầu đến khi có image cuối cùng.

## 🎯 Yêu cầu hệ thống

- **OS**: Linux (Ubuntu 22.04 recommended)
- **RAM**: Tối thiểu 8GB (khuyến nghị 16GB+)
- **Disk**: Tối thiểu 100GB free space
- **Docker**: Đã cài đặt
- **Docker Compose**: Đã cài đặt

## 📦 Bước 1: Clone Project từ GitHub

```bash
# Clone repository
cd ~
git clone https://github.com/kokonomutsu/yocto_build_multi_platform
cd yocto_multi_platform

# Kiểm tra cấu trúc project
ls -la
```

**Giải thích**: 
- Clone code từ GitHub về máy local
- Project chứa tất cả scripts và configs cần thiết

## 🐳 Bước 2: Build Docker Image

```bash
cd ~/yocto_multi_platform

# Build Docker image (lần đầu sẽ mất 5-10 phút)
docker compose build
```

**Giải thích**:
- Docker image chứa tất cả tools cần thiết để build Yocto
- Chỉ cần build 1 lần, lần sau có thể reuse

**Kiểm tra**:
```bash
docker images | grep yocto-build-image
# Nên thấy: yocto-build-image:latest
```

## 📁 Bước 3: Chuẩn bị Thư mục

```bash
cd ~/yocto_multi_platform

# Chạy script chuẩn bị
./scripts/host_prepare.sh
```

**Giải thích**:
- Script này tạo các thư mục cần thiết: `build-*`, `layers`, `downloads`, `logs`
- Set permissions đúng cho các thư mục

**Kết quả mong đợi**:
```
>>> Preparing host environment...
>>> Creating directories...
>>> Setting permissions...
>>> Using default TMPDIR (RAM disk disabled for stability)
>>> Host preparation complete!
```

## 📚 Bước 4: Fetch Yocto Layers

```bash
cd ~/yocto_multi_platform

# Fetch các Yocto layers (poky, meta-openembedded, meta-raspberrypi, etc.)
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"
```

**Giải thích**:
- Yocto sử dụng "layers" - các module chứa recipes và configs
- Script này clone các layers cần thiết từ GitHub
- Mất khoảng 5-10 phút tùy network

**Lưu ý**:
- `HOST_UID=1000 HOST_GID=1000`: Map user ID trong container với host user
- `--rm`: Tự động xóa container sau khi chạy xong

**Kết quả mong đợi**:
```
>>> Fetching Yocto layers...
>>> Cloning poky...
>>> Cloning meta-openembedded...
>>> Cloning meta-raspberrypi...
>>> All layers fetched successfully!
```

**Kiểm tra**:
```bash
ls -la layers/
# Nên thấy: poky, meta-openembedded, meta-raspberrypi
```

## ⚙️ Bước 5: Setup Build Environment

### 5.1. Cho Raspberry Pi 4:

```bash
cd ~/yocto_multi_platform

# Setup build environment cho RPi4
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh rpi4 developer"
```

### 5.2. Cho S905x3:

```bash
cd ~/yocto_multi_platform

# Setup build environment cho S905x3
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh s905x3 developer"
```

**Giải thích**:
- Script này copy config từ `products/rpi4/conf/` hoặc `products/s905x3/conf/` vào `build-rpi4/conf/` hoặc `build-s905x3/conf/`
- Khởi tạo build environment với các settings đã được tối ưu

**Kết quả mong đợi**:
```
>>> Build env setup for rpi4 (developer)
>>> Build dir: /home/yocto/build-rpi4
>>> Copied local.conf
>>> Copied bblayers.conf
>>> Build environment initialized
>>> Setup complete!
```

**Kiểm tra**:
```bash
ls -la build-rpi4/conf/
# Nên thấy: local.conf và bblayers.conf
```

## 🔨 Bước 6: Build Image

### 6.1. Build cho Raspberry Pi 4:

```bash
cd ~/yocto_multi_platform

# Build core-image-minimal cho RPi4
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh rpi4 developer core-image-minimal"
```

### 6.2. Build cho S905x3:

```bash
cd ~/yocto_multi_platform

# Build core-image-minimal cho S905x3
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh s905x3 developer core-image-minimal"
```

**Giải thích**:
- Đây là bước build chính, sẽ mất **2-4 giờ** tùy hệ thống
- Bitbake sẽ compile tất cả packages cần thiết
- Log được lưu trong `logs/` directory

**Các loại image có thể build**:
- `core-image-minimal`: Image nhỏ nhất, chỉ có essentials
- `core-image-base`: Image cơ bản với một số tools
- `core-image-sato`: Image với GUI (lớn hơn, mất thời gian hơn)

**Monitor build** (trong terminal khác):
```bash
# Xem log real-time
tail -f ~/yocto_multi_platform/logs/build-rpi4-*.log

# Hoặc check progress
cd ~/yocto_multi_platform
grep "Running task" logs/build-rpi4-*.log | tail -1
```

## ✅ Bước 7: Kiểm tra Kết quả

Sau khi build xong, image sẽ ở:

```bash
# Cho RPi4
ls -lh ~/yocto_multi_platform/build-rpi4/tmp/deploy/images/raspberrypi4/

# Cho S905x3
ls -lh ~/yocto_multi_platform/build-s905x3/tmp/deploy/images/amlogic-s905x3/
```

**Các files quan trọng**:
- `core-image-minimal-raspberrypi4.wic`: Image file để flash vào SD card
- `core-image-minimal-raspberrypi4.tar.bz2`: Tarball của rootfs
- `*.dtb`: Device tree files
- `zImage` hoặc `Image`: Kernel

## 📊 Hiểu về Build Process

### Build làm gì?

1. **Parse Recipes**: Đọc các file `.bb` (recipes) từ layers
2. **Resolve Dependencies**: Tìm tất cả packages cần thiết
3. **Download Sources**: Tải source code từ internet (lần đầu)
4. **Compile**: Build từng package (gcc, glibc, kernel, etc.)
5. **Package**: Đóng gói thành RPM/IPK
6. **Create Image**: Tạo rootfs và image file cuối cùng

### Tại sao mất thời gian?

- **Lần đầu**: Phải compile tất cả từ đầu (2-4 giờ)
- **Lần sau**: Chỉ compile những gì thay đổi (nhanh hơn nhiều)
- **Sstate Cache**: Yocto cache kết quả build để tái sử dụng

## 🐛 Troubleshooting

### Lỗi 1: Permission denied

```bash
# Fix ownership
sudo chown -R $USER:$USER ~/yocto_multi_platform/build-*
```

### Lỗi 2: Docker không chạy

```bash
# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### Lỗi 3: Hết disk space

```bash
# Check disk space
df -h

# Clean old builds (nếu cần)
cd ~/yocto_multi_platform
rm -rf build-rpi4/tmp
```

### Lỗi 4: Build bị dừng giữa chừng

```bash
# Chạy lại build (sẽ tiếp tục từ chỗ dừng)
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh rpi4 developer core-image-minimal"
```

### Lỗi 5: Layer không tồn tại

```bash
# Kiểm tra layers
ls -la ~/yocto_multi_platform/layers/

# Fetch lại nếu thiếu
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"
```

## 📝 Checklist cho Người Mới

- [ ] Clone project từ GitHub
- [ ] Build Docker image thành công
- [ ] Chạy host_prepare.sh
- [ ] Fetch layers thành công (có poky, meta-openembedded, meta-raspberrypi)
- [ ] Setup build environment (có local.conf và bblayers.conf trong build-*/conf/)
- [ ] Start build
- [ ] Monitor build progress
- [ ] Build hoàn thành không lỗi
- [ ] Tìm thấy image files trong deploy/images/

## 🎓 Các Khái niệm Quan trọng

### Layers là gì?
- Layers là các module chứa recipes (công thức build)
- Ví dụ: `meta-raspberrypi` chứa recipes cho Raspberry Pi

### Recipes là gì?
- File `.bb` mô tả cách build một package
- Ví dụ: `core-image-minimal.bb` mô tả cách tạo image minimal

### Bitbake là gì?
- Tool chính để build Yocto
- Đọc recipes, resolve dependencies, compile packages

### Build Directory là gì?
- `build-rpi4/` hoặc `build-s905x3/` chứa:
  - Config files (`conf/local.conf`, `conf/bblayers.conf`)
  - Temporary files (`tmp/`)
  - Output images (`tmp/deploy/images/`)

## 🔄 Workflow Thông thường

```
1. Clone project
   ↓
2. Build Docker image (1 lần)
   ↓
3. Fetch layers (1 lần, hoặc khi update)
   ↓
4. Setup build environment (mỗi platform)
   ↓
5. Build image
   ↓
6. Flash image vào SD card / eMMC
   ↓
7. Test trên hardware
```

## 💡 Tips

1. **Lần đầu build**: Kiên nhẫn, mất 2-4 giờ là bình thường
2. **Monitor**: Luôn mở terminal khác để xem log
3. **Disk space**: Đảm bảo có ít nhất 100GB free
4. **Network**: Build cần internet để download sources
5. **Sstate cache**: Giữ lại `sstate-cache/` để build nhanh hơn lần sau

## 📞 Cần Giúp?

- Xem logs: `tail -f logs/build-*.log`
- Check documentation: `cat README.md`
- Xem changelog: `cat CHANGELOG.md`

---

**Chúc bạn build thành công! 🎉**

