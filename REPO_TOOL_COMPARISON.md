# 🔄 So sánh: Repo Tool vs Git Clone

## 📊 Tổng quan

### yocto_multi_platform
**Không sử dụng repo tool** - Dùng git clone trực tiếp

### yocto-nanopc-t6 (project gốc)
**Sử dụng repo tool** - Quản lý multiple repositories qua manifest files

## 🔍 Chi tiết

### yocto_multi_platform Approach

**Method**: Git clone trực tiếp từng layer

**Script**: `scripts/fetch_layers.sh`

**Cách hoạt động**:
```bash
# Clone từng layer một
git clone -b kirkstone --depth 1 https://git.yoctoproject.org/git/poky
git clone -b kirkstone --depth 1 https://github.com/openembedded/meta-openembedded.git
git clone -b kirkstone --depth 1 https://git.yoctoproject.org/git/meta-rockchip
# ... etc
```

**Ưu điểm**:
- ✅ Đơn giản, dễ hiểu
- ✅ Không cần cài đặt repo tool
- ✅ Dễ debug (biết rõ từng layer được clone từ đâu)
- ✅ Kiểm soát tốt hơn (có thể chọn branch/revision cho từng layer)

**Nhược điểm**:
- ❌ Phải maintain danh sách layers trong script
- ❌ Không có cơ chế snapshot/revision pinning tự động
- ❌ Phải update script khi thêm/bớt layer

### yocto-nanopc-t6 Approach

**Method**: Repo tool với manifest files

**Manifest**: `default.xml`, `default_mainline.xml`, etc.

**Cách hoạt động**:
```bash
# Initialize với manifest
repo init --depth=1 -u git@github.com:thangbk/yocto-nanopc-t6.git \
    -m default.xml \
    --repo-url=https://git.codelinaro.org/clo/tools/repo.git \
    --repo-branch=qc-stable

# Sync tất cả repositories
repo sync -j16
```

**Ưu điểm**:
- ✅ Quản lý nhiều repositories dễ dàng
- ✅ Có thể pin revisions cụ thể (reproducibility)
- ✅ Dễ maintain (chỉ cần update manifest)
- ✅ Hỗ trợ snapshot (có thể quay lại version cũ)

**Nhược điểm**:
- ❌ Cần cài đặt repo tool
- ❌ Phức tạp hơn cho người mới
- ❌ Cần authentication cho private repos

## 📦 Repository Structure

### yocto_multi_platform
```
yocto_multi_platform/
├── layers/              # All layers cloned here
│   ├── poky/
│   ├── meta-openembedded/
│   ├── meta-rockchip/
│   └── ...
├── scripts/
│   └── fetch_layers.sh  # Git clone script
└── products/
    └── rk3588/
        └── conf/         # Build configs
```

### yocto-nanopc-t6 (với repo tool)
```
nanopc-t6/
├── .repo/               # Repo tool metadata
│   └── manifests/       # Manifest files
├── poky/                # Cloned by repo
├── meta-openembedded/   # Cloned by repo
├── meta-rockchip/       # Cloned by repo
├── meta-marine/         # Custom layer (from thangbk/yocto-nanopc-t6)
└── build-marine/        # Build directory
```

## 🔑 Key Differences

| Aspect | yocto_multi_platform | yocto-nanopc-t6 |
|--------|---------------------|-----------------|
| **Tool** | Git clone | Repo tool |
| **Config** | Script (fetch_layers.sh) | Manifest XML |
| **Revision Control** | Branch trong script | Revision trong manifest |
| **Custom Layer** | `products/rk3588/` | `meta-marine/` |
| **Build Config** | `products/rk3588/conf/` | `meta-marine/build-conf/` |
| **Setup Script** | `setup_env.sh` | `source-build-marine-image.sh` |

## 📝 Custom Layer: meta-marine

Từ manifest `default.xml`:
```xml
<project name="thangbk/yocto-nanopc-t6" remote="github" revision="meta-marine">
    <copyfile src="meta-marine/source-build-marine-image.sh" dest="source-build-marine-image.sh"/>
</project>
```

**Branch `meta-marine` chứa**:
- `meta-marine/` layer với build configs
- `meta-marine/source-build-marine-image.sh` - Build setup script
- Có thể có custom U-Boot/kernel configs cho nanopc-t6

**Để access**:
- Repository: `https://github.com/thangbk/yocto-nanopc-t6`
- Branch: `meta-marine`
- Cần authentication (SSH key hoặc token)

## 💡 Recommendations

### Nếu muốn giữ approach hiện tại (git clone):
- ✅ Đơn giản, dễ maintain
- ✅ Không cần thay đổi nhiều
- ⚠️ Cần tự maintain danh sách layers

### Nếu muốn chuyển sang repo tool:
- ✅ Có thể pin revisions cụ thể
- ✅ Dễ quản lý nhiều repositories
- ❌ Cần refactor scripts
- ❌ Cần cài đặt repo tool

## 🔍 Tìm Custom Configs

Để tìm U-Boot/kernel configs cho nanopc-t6:

1. **Check meta-marine layer** (nếu có access):
   ```bash
   git clone -b meta-marine https://github.com/thangbk/yocto-nanopc-t6.git
   cd yocto-nanopc-t6/meta-marine
   find . -name "*uboot*" -o -name "*u-boot*" -o -name "*nanopc*"
   ```

2. **Check build-conf directory**:
   ```bash
   # Trong meta-marine/build-conf/
   # Có thể có local.conf, bblayers.conf với U-Boot configs
   ```

3. **Check FriendlyElec official sources**:
   - Wiki: https://wiki.friendlyelec.com/wiki/index.php/NanoPC-T6
   - GitHub: https://github.com/friendlyarm (có thể có U-Boot configs)

## 📚 References

- [Repo Tool Documentation](https://source.android.com/docs/setup/download)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [NanoPC-T6 Wiki](https://wiki.friendlyelec.com/wiki/index.php/NanoPC-T6)

