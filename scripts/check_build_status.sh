#!/bin/bash
# Check build status for all platforms
# Works both from host and inside Docker container

echo "=== Yocto Build Status Check ==="
echo ""

# Detect environment (Docker container or host)
if [ -d "/home/yocto" ] && [ -f "/home/yocto/layers/poky/bitbake/bin/bitbake" ] 2>/dev/null; then
    # Running inside Docker container
    BASE_DIR="/home/yocto"
    ENV_TYPE="Docker"
else
    # Running on host - find project root
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
    ENV_TYPE="Host"
fi

echo "📍 Environment: $ENV_TYPE"
echo ""

# Check running builds (both in container and host)
echo "📊 Running Builds:"
# Check bitbake processes
BITBAKE_RUNNING=$(ps aux | grep -E "bitbake|build.sh" | grep -v grep | wc -l)
# Check Docker containers (only works from host)
DOCKER_RUNNING=0
if [ "$ENV_TYPE" = "Host" ]; then
    DOCKER_RUNNING=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -E "yocto|build" | wc -l)
fi

if [ "$BITBAKE_RUNNING" -gt 0 ] || [ "$DOCKER_RUNNING" -gt 0 ]; then
    if [ "$BITBAKE_RUNNING" -gt 0 ]; then
        echo "  ✅ Found $BITBAKE_RUNNING build process(es)"
        ps aux | grep -E "bitbake|build.sh" | grep -v grep | head -3 | awk '{print "    PID:", $2, "|", $11, $12, $13, $14, $15}'
    fi
    if [ "$DOCKER_RUNNING" -gt 0 ]; then
        echo "  ✅ Found $DOCKER_RUNNING Docker container(s) running"
        docker ps --format '  {{.Names}} - {{.Status}}' 2>/dev/null | grep -E "yocto|build" | head -3
    fi
else
    echo "  ⚠️  No build processes running"
fi
echo ""

# Check logs per platform
echo "📝 Latest Build Logs (per platform):"
LOGS_DIR="$BASE_DIR/logs"
for platform in s905x3 rpi4 rpi0w; do
    if [ -d "$LOGS_DIR" ]; then
        LATEST_LOG=$(ls -t "$LOGS_DIR"/build-${platform}-*.log 2>/dev/null | head -1)
        if [ -n "$LATEST_LOG" ] && [ -f "$LATEST_LOG" ]; then
            echo "  $platform: $(basename $LATEST_LOG)"
            # Check if build completed
            if grep -q "Tasks Summary.*succeeded\|Build completed successfully" "$LATEST_LOG" 2>/dev/null; then
                echo "    ✅ Build completed"
                tail -2 "$LATEST_LOG" 2>/dev/null | sed 's/^/      /'
            elif grep -q "ERROR\|Failed" "$LATEST_LOG" 2>/dev/null; then
                echo "    ❌ Build failed"
                grep -i "ERROR\|Failed" "$LATEST_LOG" 2>/dev/null | tail -1 | sed 's/^/      /'
            else
                echo "    ⏳ Build in progress"
                tail -2 "$LATEST_LOG" 2>/dev/null | sed 's/^/      /'
            fi
        else
            echo "  $platform: No logs found"
        fi
    else
        echo "  $platform: Logs directory not found"
    fi
done
echo ""

# Check build directories and images
echo "📦 Build Directories & Images:"
for platform in s905x3 rpi4 rpi0w; do
    BUILD_DIR="$BASE_DIR/build-${platform}"
    if [ -d "$BUILD_DIR" ]; then
        # Check if deploy/images exists
        if [ -d "$BUILD_DIR/tmp/deploy/images" ]; then
            # Check for images
            IMAGES=$(find "$BUILD_DIR/tmp/deploy/images" -type f \( -name "*.wic" -o -name "*.ext3" -o -name "*.tar.bz2" -o -name "*.img" \) 2>/dev/null | wc -l)
            if [ "$IMAGES" -gt 0 ]; then
                echo "  ✅ $platform: COMPLETE - $IMAGES image(s) found"
                find "$BUILD_DIR/tmp/deploy/images" -type f \( -name "*.wic" -o -name "*.ext3" -o -name "*.tar.bz2" -o -name "*.img" \) 2>/dev/null | head -2 | sed "s|^$BASE_DIR/||" | sed 's/^/    /'
            else
                echo "  ⏳ $platform: IN PROGRESS - Build directory exists but no images yet"
            fi
        else
            echo "  ⚠️  $platform: Build directory exists but no deploy/images (early stage)"
        fi
    else
        echo "  ❌ $platform: No build directory (not started)"
    fi
done
echo ""

# Check disk space
echo "💾 Disk Space:"
if [ "$ENV_TYPE" = "Docker" ]; then
    if df -h /home/yocto >/dev/null 2>&1; then
        df -h /home/yocto | tail -1 | awk '{print "  Available: " $4 " / " $2 " (" $5 " used)"}'
    else
        df -h / | tail -1 | awk '{print "  Available: " $4 " / " $2 " (" $5 " used)"}'
    fi
else
    # From host, check project directory
    df -h "$BASE_DIR" 2>/dev/null | tail -1 | awk '{print "  Available: " $4 " / " $2 " (" $5 " used)"}' || df -h / | tail -1 | awk '{print "  Available: " $4 " / " $2 " (" $5 " used)"}'
fi
echo ""

# Check system resources
echo "🖥️  System Resources:"
echo "  CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "  Memory: $(free -h | grep Mem | awk '{print "Used: " $3 " / " $2 " (" $3/$2*100 "%)"}')"
echo ""

echo "=== Status Check Complete ==="

