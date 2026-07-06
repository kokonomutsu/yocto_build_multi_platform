# 📦 Manifest Files

Manifest files định nghĩa các repositories và revisions được sử dụng trong yocto_multi_platform.

## 📄 Available Manifests

### `default.xml` (Production)
- **Purpose**: Production builds với pinned revisions
- **Branches**: kirkstone (stable)
- **Use case**: Reproducible builds, production releases

### `default_mainline.xml` (Development)
- **Purpose**: Development builds với latest code
- **Branches**: master (latest)
- **Use case**: Testing new features, development

### `nanopc-t6-navonz_v1.xml` (RK3588 pinned snapshot)
- **Purpose**: Reproducible NanoPC-T6 build với commit đã verify
- **Path**: `layers-pin/` (không ảnh hưởng `layers/` kirkstone)
- **Use case**: `scripts/setup_env.sh rk3588 navonz_v1`

## 🚀 Usage

### Initialize Repo Tool

```bash
# Initialize với default manifest (production)
./scripts/init_repo.sh

# Hoặc với mainline manifest (development)
./scripts/init_repo.sh default_mainline.xml
```

### Sync Repositories

```bash
# Sync tất cả repositories
repo sync -j16

# Hoặc dùng script (tự động detect method)
./scripts/fetch_layers.sh
```

### Switch Manifest

```bash
# Switch sang manifest khác
repo init -m manifests/default_mainline.xml
repo sync -j16
```

## 📋 Layers Included

### Core Layers
- `poky`: Core Yocto Project
- `meta-openembedded`: Extended functionality

### Platform-Specific Layers
- `meta-raspberrypi`: Raspberry Pi support (rpi4, rpi0w)
- `meta-meson`: Amlogic support (s905x3)
- `meta-rockchip`: Rockchip support (rk3588)
- `meta-arm`: ARM architecture support (rk3588)

## 🔧 Customization

Để thêm/bớt layers, edit manifest file:

```xml
<project name="layer-name" remote="remote-name" path="layers/layer-name" revision="branch-name"/>
```

Sau đó:
```bash
repo sync -j16
```

## 📚 References

- [Repo Tool Documentation](https://source.android.com/docs/setup/download)
- [Manifest Format](https://source.android.com/docs/setup/create/manifest)

