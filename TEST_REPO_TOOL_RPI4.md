# 🧪 Test Repo Tool với Raspberry Pi 4

## 📋 Process Overview

1. **Initialize repo tool** (lần đầu tiên)
2. **Fetch layers** (sử dụng repo tool)
3. **Setup build environment** (cho RPi4)
4. **Build image** (core-image-minimal)

## 🚀 Step-by-Step Commands

### Step 1: Prepare Host Environment

```bash
cd /home/picopiece/yocto_multi_platform

# Ensure Docker is running
docker compose ps

# Prepare directories
./scripts/host_prepare.sh
```

### Step 2: Initialize Repo Tool (Lần đầu tiên)

```bash
# Initialize repo tool với default manifest (kirkstone)
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/init_repo.sh"
```

**Expected output:**
```
>>> Initializing repo tool...
>>> Manifest: default.xml
>>> Initializing with local manifest: manifests/default.xml
>>> Repo initialized successfully!
```

### Step 3: Fetch Layers

```bash
# Fetch layers using repo tool
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"
```

**Expected output:**
```
>>> Detected repo tool - using repo sync...
>>> Syncing repositories (this may take a while)...
>>> Layers fetched using repo tool!
```

**Alternative (nếu repo tool chưa init):**
```bash
# Script sẽ tự động fallback về git clone
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"
```

### Step 4: Verify Layers

```bash
# Check if layers are cloned
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "ls -la layers/"
```

**Expected:**
```
layers/
├── poky/
├── meta-openembedded/
├── meta-raspberrypi/
├── meta-meson/
├── meta-rockchip/
└── meta-arm/
```

### Step 5: Setup Build Environment

```bash
# Setup build environment cho RPi4
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh rpi4 developer"
```

**Expected output:**
```
>>> Build env setup for rpi4 (developer)
>>> Build dir: /home/yocto/build-rpi4
>>> Copied local.conf
>>> Copied bblayers.conf
>>> Build environment initialized
>>> Setup complete!
```

### Step 6: Build Image

```bash
# Build core-image-minimal cho RPi4
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh rpi4 developer core-image-minimal"
```

**Expected:**
- Build sẽ mất 2-4 giờ (lần đầu)
- Log được lưu tại: `logs/build-rpi4-*.log`
- Image output: `build-rpi4/tmp/deploy/images/raspberrypi4/`

## 🔄 Quick Test (All-in-One)

```bash
cd /home/picopiece/yocto_multi_platform

# 1. Prepare
./scripts/host_prepare.sh

# 2. Initialize repo tool (chỉ lần đầu)
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/init_repo.sh"

# 3. Fetch layers
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"

# 4. Setup & Build
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh rpi4 developer && scripts/build.sh rpi4 developer core-image-minimal"
```

## 🐳 Docker Process Flow

```
Host Machine
    │
    ├─> docker compose run --rm yocto
    │       │
    │       └─> Container: /home/yocto
    │               │
    │               ├─> scripts/init_repo.sh
    │               │   └─> Creates .repo/ directory
    │               │
    │               ├─> scripts/fetch_layers.sh
    │               │   └─> Detects .repo/ → uses repo sync
    │               │       └─> Clones layers/ from manifest
    │               │
    │               ├─> scripts/setup_env.sh rpi4 developer
    │               │   └─> Creates build-rpi4/conf/
    │               │       └─> Copies from products/rpi4/conf/
    │               │
    │               └─> scripts/build.sh rpi4 developer core-image-minimal
    │                   └─> bitbake core-image-minimal
    │                       └─> Output: build-rpi4/tmp/deploy/images/
    │
    └─> Volumes mounted:
        ├─> ./layers → /home/yocto/layers
        ├─> ./build-rpi4 → /home/yocto/build-rpi4
        ├─> ./products → /home/yocto/products
        └─> ./logs → /home/yocto/logs
```

## ✅ Verification Steps

### Check Repo Tool Status

```bash
# Inside container
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "cd /home/yocto && repo status"
```

### Check Manifest

```bash
# View current manifest
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "cd /home/yocto && repo manifest"
```

### Check Layers

```bash
# List all layers
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "ls -la layers/"
```

### Check Build Config

```bash
# Verify build config
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "cat build-rpi4/conf/local.conf | grep MACHINE"
```

**Expected:** `MACHINE ??= "raspberrypi4"`

## 🔍 Troubleshooting

### Repo Tool Not Found

```bash
# Install repo tool (inside container)
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "
    mkdir -p ~/bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    export PATH=~/bin:\$PATH
    repo --version
"
```

### Repo Sync Fails

```bash
# Retry with verbose
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "cd /home/yocto && repo sync -v -j4"
```

### Fallback to Git Clone

Nếu repo tool không work, script tự động fallback:
```bash
# Script sẽ detect và dùng git clone
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"
```

## 📊 Comparison: Repo Tool vs Git Clone

| Step | Repo Tool | Git Clone |
|------|-----------|-----------|
| Initialize | `scripts/init_repo.sh` | Not needed |
| Fetch | `repo sync -j16` | `git clone` per layer |
| Status | `repo status` | `git status` per layer |
| Update | `repo sync` | Manual `git pull` per layer |
| Manifest | `manifests/default.xml` | `scripts/fetch_layers.sh` |

## 🎯 Expected Results

Sau khi build xong:

```bash
# Check build output
ls -lh build-rpi4/tmp/deploy/images/raspberrypi4/

# Expected files:
# - core-image-minimal-raspberrypi4-*.rootfs.ext3
# - core-image-minimal-raspberrypi4-*.rootfs.tar.bz2
# - Image
# - *.dtb files
```

## 📝 Notes

- **First time**: Repo tool initialization + sync mất ~10-15 phút
- **Subsequent**: Chỉ sync changes, nhanh hơn nhiều
- **Build time**: 2-4 giờ lần đầu, nhanh hơn lần sau (có sstate cache)
- **Disk space**: Cần ~50GB cho build directory

