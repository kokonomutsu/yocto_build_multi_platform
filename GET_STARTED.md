# 🚀 Bắt đầu nhanh - 5 phút

## Cho người mới hoàn toàn

### Cách 1: Dùng Quick Build Script (Khuyến nghị)

```bash
# Clone project
git clone https://github.com/YOUR_USERNAME/yocto_multi_platform.git
cd yocto_multi_platform

# Chạy script tự động (sẽ làm tất cả các bước)
./scripts/quick_build.sh rpi4 core-image-minimal
```

Script sẽ tự động:
1. ✅ Build Docker image (nếu chưa có)
2. ✅ Tạo thư mục cần thiết
3. ✅ Fetch Yocto layers (nếu chưa có)
4. ✅ Setup build environment
5. ✅ Build image

### Cách 2: Làm thủ công (Hiểu rõ từng bước)

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/yocto_multi_platform.git
cd yocto_multi_platform

# 2. Build Docker image
docker compose build

# 3. Prepare
./scripts/host_prepare.sh

# 4. Fetch layers (supports both repo tool and git clone)
# Option A: Using repo tool (recommended for production/team)
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/init_repo.sh && scripts/fetch_layers.sh"

# Option B: Using git clone (traditional, good for development)
# Auto-detected if repo tool not initialized
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"

# 5. Setup (chọn 1 trong 2)
# Cho RPi4:
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh rpi4 developer"

# Cho S905x3:
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh s905x3 developer"

# 6. Build (chọn 1 trong 2)
# Cho RPi4:
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh rpi4 developer core-image-minimal"

# Cho S905x3:
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh s905x3 developer core-image-minimal"
```

## ⏱️ Thời gian ước tính

- **Docker build**: 5-10 phút (1 lần)
- **Fetch layers**: 5-10 phút (1 lần)
- **Build image**: 2-4 giờ (lần đầu), nhanh hơn lần sau

## 📖 Tài liệu chi tiết

- **QUICK_START_GUIDE.md**: Hướng dẫn từng bước chi tiết với giải thích
- **README.md**: Tổng quan project
- **Troubleshooting**: Xem trong QUICK_START_GUIDE.md

## ❓ Câu hỏi thường gặp

**Q: Tại sao phải dùng Docker?**  
A: Docker đảm bảo môi trường build giống nhau trên mọi máy, tránh lỗi do khác biệt hệ thống.

**Q: Build mất bao lâu?**  
A: Lần đầu 2-4 giờ. Lần sau chỉ vài phút vì có sstate cache.

**Q: Image ở đâu sau khi build xong?**  
A: `build-rpi4/tmp/deploy/images/raspberrypi4/` hoặc `build-s905x3/tmp/deploy/images/amlogic-s905x3/`

**Q: Có thể build nhiều platform cùng lúc không?**  
A: Có, nhưng tốn nhiều tài nguyên. Nên build từng cái một.

## 🆘 Cần giúp?

1. Xem **QUICK_START_GUIDE.md** để hiểu chi tiết
2. Check logs: `tail -f logs/build-*.log`
3. Xem troubleshooting section trong QUICK_START_GUIDE.md

---

**Bắt đầu ngay**: `./scripts/quick_build.sh rpi4 core-image-minimal` 🚀

