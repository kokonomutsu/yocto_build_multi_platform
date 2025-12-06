# Build Monitoring Guide

## Quick Commands

### Check Build Status
```bash
# Inside Docker
HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/check_build_status.sh"

# Or from host (if scripts are accessible)
./scripts/check_build_status.sh
```

### Start Build in Background
```bash
./scripts/start_build_background.sh <platform> <profile> <image>
# Example:
./scripts/start_build_background.sh rpi0w developer core-image-minimal
```

### Monitor Builds (Live)
```bash
./scripts/monitor_builds.sh
# Shows live updates every 5 seconds
# Press Ctrl+C to stop
```

### Check Logs Manually
```bash
# List all logs
ls -lth logs/*.log

# Follow latest log
tail -f logs/$(ls -t logs/*.log | head -1)

# Check specific build
tail -f logs/build-<platform>-<image>-*.log
```

### Check Build Progress
```bash
# Check running processes
ps aux | grep bitbake

# Check Docker containers
docker ps

# Check build directories
ls -lh build-*/tmp/deploy/images/*/
```

## Build Status Indicators

- ✅ **Running**: Build process is active
- ⚠️  **Stopped**: Build directory exists but no active process
- ❌ **Not Started**: No build directory
- 📦 **Complete**: Image files found in deploy/images

## Example Workflow

1. **Start S905x3 build** (if not already running):
   ```bash
   ./scripts/start_build_background.sh s905x3 developer core-image-minimal
   ```

2. **Start Pi Zero W build**:
   ```bash
   ./scripts/start_build_background.sh rpi0w developer core-image-minimal
   ```

3. **Monitor both builds**:
   ```bash
   ./scripts/monitor_builds.sh
   ```

4. **Check status anytime**:
   ```bash
   ./scripts/check_build_status.sh
   ```

5. **Check logs when you wake up**:
   ```bash
   tail -100 logs/build-rpi0w-*.log
   tail -100 logs/build-s905x3-*.log
   ```
