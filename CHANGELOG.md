# Changelog - Yocto Multi-Platform Build System

## [2025-12-07] - Project Rebuild & Fixes

### ✅ Tạo lại Project Structure
- Tạo lại toàn bộ cấu trúc project từ đầu
- Tạo 7 build scripts với đầy đủ chức năng
- Tạo config cho S905x3 và Raspberry Pi 4

### 🔧 Dockerfile Fixes
- **Fix pylint3 → pylint**: Ubuntu 22.04 không có package `pylint3`, thay bằng `pylint`
- **Thêm package `file`**: Required by Yocto HOSTTOOLS, thiếu sẽ gây lỗi build

### ⚙️ Configuration Changes

#### DL_DIR & SSTATE_DIR
- **Trước**: Dùng `/mnt/ssd/downloads-${PLATFORM}` và `/mnt/ssd/sstate-cache-${PLATFORM}`
- **Sau**: Dùng `/home/yocto/downloads` và `/home/yocto/sstate-cache`
- **Lý do**: `/mnt/ssd` thuộc root, user trong container không có quyền write
- **Áp dụng cho**: Cả S905x3 và RPi4 configs

#### Layer Configuration
- **Removed**: `meta-pico-custom` layer khỏi RPi4 `bblayers.conf` (layer không tồn tại)

### 📝 Scripts Updates
- **fetch_layers.sh**: Handle meta-amlogic clone failure gracefully (có thể cần authentication)

### 📦 Git Repository
- Tạo Git repository với `.gitignore` phù hợp
- Initial commit với tất cả source files
- 4 commits:
  1. Initial commit: Yocto multi-platform build system
  2. Fix Dockerfile: replace pylint3 with pylint
  3. Add file package to Dockerfile
  4. Fix: Use local directories instead of /mnt/ssd

### 🎯 Current Status
- ✅ Docker image built successfully
- ✅ Layers fetched (poky, meta-openembedded, meta-raspberrypi)
- ✅ RPi4 build đang chạy (54.5% complete)
- ✅ Config đã được fix và test

### 📋 Files Changed
- `Dockerfile`: pylint3 → pylint, thêm `file` package
- `products/rpi4/conf/local.conf`: DL_DIR, SSTATE_DIR paths
- `products/s905x3/conf/local.conf`: DL_DIR, SSTATE_DIR paths
- `products/rpi4/conf/bblayers.conf`: Removed meta-pico-custom
- `scripts/fetch_layers.sh`: Handle meta-amlogic gracefully
- `.gitignore`: Created with proper Yocto ignores

### 🔍 Known Issues & Solutions
- **Issue**: Permission denied với `/mnt/ssd`
  - **Solution**: Dùng local directories (`/home/yocto/downloads`, `/home/yocto/sstate-cache`)
  - **Future**: Có thể fix permission với `sudo chown -R 1000:1000 /mnt/ssd/*` nếu muốn dùng SSD

- **Issue**: meta-amlogic clone fails
  - **Solution**: Script handle gracefully, không block build cho RPi4

### 📖 Documentation
- `README.md`: Tổng quan project
- `NEXT_STEPS.md`: Hướng dẫn các bước tiếp theo
- `SETUP_YOCTO_ENV.md`: Hướng dẫn setup chi tiết
- `CHANGELOG.md`: This file

