#!/bin/bash
# Check build status for all platforms

echo "=== Yocto Build Status Check ==="
echo ""

# Check running builds
echo "📊 Running Builds:"
RUNNING=$(ps aux | grep -E "bitbake|build.sh" | grep -v grep | wc -l)
if [ "$RUNNING" -gt 0 ]; then
    echo "  ✅ Found $RUNNING build process(es)"
    ps aux | grep -E "bitbake|build.sh" | grep -v grep | awk '{print "    PID:", $2, "|", $11, $12, $13, $14, $15}'
else
    echo "  ⚠️  No build processes running"
fi
echo ""

# Check latest logs
echo "📝 Latest Build Logs:"
if [ -d "/home/yocto/logs" ]; then
    LATEST_LOG=$(ls -t /home/yocto/logs/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
        echo "  Latest: $(basename $LATEST_LOG)"
        echo "  Last 5 lines:"
        tail -5 "$LATEST_LOG" 2>/dev/null | sed 's/^/    /'
    else
        echo "  No log files found"
    fi
else
    echo "  Logs directory not found"
fi
echo ""

# Check build directories
echo "📦 Build Directories:"
for platform in s905x3 rpi4 rpi0w; do
    BUILD_DIR="/home/yocto/build-${platform}"
    if [ -d "$BUILD_DIR" ]; then
        # Check if build is in progress
        if [ -f "$BUILD_DIR/tmp/deploy/images" ] || [ -d "$BUILD_DIR/tmp/deploy/images" ]; then
            echo "  ✅ $platform: Build directory exists"
            # Check for images
            IMAGES=$(find "$BUILD_DIR/tmp/deploy/images" -name "*.wic" -o -name "*.ext3" -o -name "*.tar.bz2" 2>/dev/null | wc -l)
            if [ "$IMAGES" -gt 0 ]; then
                echo "    📦 Found $IMAGES image file(s)"
            fi
        else
            echo "  ⚠️  $platform: Build directory exists but no deploy/images"
        fi
    else
        echo "  ❌ $platform: No build directory"
    fi
done
echo ""

# Check disk space
echo "💾 Disk Space:"
df -h /home/picopiece | tail -1 | awk '{print "  Available: " $4 " / " $2 " (" $5 " used)"}'
echo ""

# Check system resources
echo "🖥️  System Resources:"
echo "  CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "  Memory: $(free -h | grep Mem | awk '{print "Used: " $3 " / " $2 " (" $3/$2*100 "%)"}')"
echo ""

echo "=== Status Check Complete ==="

