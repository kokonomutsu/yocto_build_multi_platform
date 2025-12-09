# Yocto Multi-Platform Build System

Build system cho Yocto Project hỗ trợ nhiều platform (S905x3, Raspberry Pi 4).

## 📋 Cấu trúc Project

```
yocto_multi_platform/
├── Dockerfile                  # Docker image definition
├── docker-compose.yml          # Docker service configuration
├── scripts/                    # Build scripts
│   ├── fetch_layers.sh        # Clone Yocto layers
│   ├── setup_env.sh           # Setup build environment
│   ├── build.sh               # Build image
│   ├── host_prepare.sh        # Host-side preparation
│   ├── nuke-and-rebuild.sh    # Clean rebuild
│   ├── rebuild-image.sh       # Rebuild specific image
│   └── fetch_missing_sources.sh # Fetch missing sources
├── products/                   # Platform configurations
│   ├── s905x3/
│   │   └── conf/
│   │       ├── local.conf
│   │       └── bblayers.conf
│   └── rpi4/
│       └── conf/
│           ├── local.conf
│           └── bblayers.conf
├── build-s905x3/              # Build directory cho S905x3
├── build-rpi4/                # Build directory cho RPi4
├── layers/                     # Yocto layers (cloned)
├── downloads/                  # Downloaded sources
├── sstate-cache/               # Shared state cache
└── logs/                       # Build logs
```

## 🚀 Quick Start

### 1. Build Docker Image

```bash
cd /home/picopiece/yocto_multi_platform
docker compose build
```

### 2. Prepare Host Environment

```bash
./scripts/host_prepare.sh
```

### 3. Fetch Yocto Layers

**Option A: Using Repo Tool (Recommended for Production/Team)**
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/init_repo.sh && scripts/fetch_layers.sh"
```

**Option B: Using Git Clone (Traditional - Good for Development)**
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"
```

> **Note**: The `fetch_layers.sh` script automatically detects which method to use:
> - If `.repo/manifest.xml` exists → Uses repo tool (`repo sync`)
> - If not → Uses git clone method
> 
> See [Layer Management Methods](#layer-management-methods) section below for details.

### 4. Setup Build Environment

#### Cho S905x3:
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh s905x3 developer"
```

#### Cho Raspberry Pi 4:
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh rpi4 developer"
```

### 5. Build Image

#### S905x3:
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh s905x3 developer core-image-minimal"
```

#### Raspberry Pi 4:
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh rpi4 developer core-image-minimal"
```

## ⚙️ Configuration

### Performance Settings

- **Threads**: 20 threads (optimized for stability)
- **RAM Disk**: Disabled (using default TMPDIR)
- **Disk Monitoring**: Configured with thresholds

### Optimizations Applied

- Git shallow clones (`BB_GIT_SHALLOW = "1"`)
- GDB fix (removed or downgraded to avoid linking errors)
- Package classes: RPM
- Local directories for downloads and sstate cache (permission-safe)

## 📝 Notes

- Always use `HOST_UID=1000 HOST_GID=1000` when running docker compose
- Use `docker compose` (not `docker-compose`)
- Build logs are saved in `logs/` directory
- Images are located in `build-*/tmp/deploy/images/`
- Downloads and sstate cache use local directories (`/home/yocto/downloads`, `/home/yocto/sstate-cache`)

## 🔧 Troubleshooting

### Permission Issues
```bash
sudo chown -R picopiece:picopiece build-*
```

### Clean Rebuild
```bash
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/nuke-and-rebuild.sh s905x3"
```

### Check Environment
```bash
/home/picopiece/check_env.sh
```

## Layer Management Methods

This project supports **two layer management methods** with automatic detection:

### 1. Git Clone (Traditional Method)
- **Use case**: Development, quick testing, single platform builds
- **How it works**: Clones each layer directly from Git repositories
- **Command**: `scripts/fetch_layers.sh` (when `.repo` doesn't exist)
- **Pros**: 
  - Simple setup, no configuration needed
  - Fast for quick builds
  - Good for development and testing
- **Cons**: 
  - No version pinning (always uses latest branch)
  - Manual layer management
  - Not ideal for reproducible builds

### 2. Repo Tool (Advanced Method)
- **Use case**: Production builds, team collaboration, reproducible builds
- **How it works**: Manages all layers through manifest files (`.xml`)
- **Command**: `scripts/init_repo.sh && scripts/fetch_layers.sh`
- **Pros**: 
  - Version pinning via manifest files
  - Reproducible builds across team
  - Easy to share configurations
  - Better for multi-platform management
- **Cons**: 
  - Requires initial setup with manifest
  - Slightly more complex

### Hybrid Mechanism

The `fetch_layers.sh` script automatically detects which method to use:

```bash
# Auto-detection logic:
if [ -f ".repo/manifest.xml" ]; then
    # Use repo tool (repo sync)
else
    # Use git clone method
fi
```

**You can switch between methods at any time:**
- To use repo tool: Run `scripts/init_repo.sh` first
- To use git clone: Remove `.repo` directory: `rm -rf .repo`

For detailed comparison, see [REPO_TOOL_COMPARISON.md](REPO_TOOL_COMPARISON.md).

