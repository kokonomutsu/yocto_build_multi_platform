#!/bin/bash
# Quick check when you wake up

echo "🌅 Good morning! Checking build status..."
echo ""

# Check latest logs
echo "📝 Latest Build Logs:"
echo "--- S905x3 ---"
LATEST_S905X3=$(ls -t logs/build-s905x3-*.log 2>/dev/null | head -1)
if [ -n "$LATEST_S905X3" ]; then
    echo "Latest: $(basename $LATEST_S905X3)"
    echo "Last 10 lines:"
    tail -10 "$LATEST_S905X3" 2>/dev/null | sed 's/^/  /'
    echo ""
    # Check for errors
    ERRORS=$(grep -i "error\|failed" "$LATEST_S905X3" | tail -3)
    if [ -n "$ERRORS" ]; then
        echo "⚠️  Recent errors:"
        echo "$ERRORS" | sed 's/^/  /'
    else
        echo "✅ No recent errors"
    fi
else
    echo "No S905x3 logs found"
fi
echo ""

echo "--- Pi Zero W ---"
LATEST_RPI0W=$(ls -t logs/build-rpi0w-*.log 2>/dev/null | head -1)
if [ -n "$LATEST_RPI0W" ]; then
    echo "Latest: $(basename $LATEST_RPI0W)"
    echo "Last 10 lines:"
    tail -10 "$LATEST_RPI0W" 2>/dev/null | sed 's/^/  /'
    echo ""
    # Check for errors
    ERRORS=$(grep -i "error\|failed" "$LATEST_RPI0W" | tail -3)
    if [ -n "$ERRORS" ]; then
        echo "⚠️  Recent errors:"
        echo "$ERRORS" | sed 's/^/  /'
    else
        echo "✅ No recent errors"
    fi
else
    echo "No rpi0w logs found"
fi
echo ""

# Check for completed images
echo "📦 Completed Images:"
for platform in s905x3 rpi0w; do
    BUILD_DIR="build-${platform}"
    if [ -d "$BUILD_DIR/tmp/deploy/images" ]; then
        IMAGES=$(find "$BUILD_DIR/tmp/deploy/images" -name "*.wic" -o -name "*.ext3" -o -name "*.tar.bz2" 2>/dev/null | wc -l)
        if [ "$IMAGES" -gt 0 ]; then
            echo "  ✅ $platform: $IMAGES image(s) found"
            find "$BUILD_DIR/tmp/deploy/images" -name "*.wic" -o -name "*.ext3" -o -name "*.tar.bz2" 2>/dev/null | head -3 | sed 's/^/    /'
        else
            echo "  ⏳ $platform: Build in progress (no images yet)"
        fi
    else
        echo "  ❌ $platform: No build directory"
    fi
done
echo ""

# Check running processes
echo "🔄 Running Builds:"
RUNNING=$(ps aux | grep -E "bitbake|build.sh|docker.*yocto.*build" | grep -v grep | wc -l)
if [ "$RUNNING" -gt 0 ]; then
    echo "  ✅ $RUNNING build process(es) still running"
else
    echo "  ⏸️  No active builds"
fi
echo ""

echo "=== Check Complete ==="
