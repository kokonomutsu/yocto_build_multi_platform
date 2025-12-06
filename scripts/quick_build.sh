#!/bin/bash
# Quick build script cho người mới - tự động hóa các bước

set -e

PLATFORM=${1:-rpi4}
IMAGE=${2:-core-image-minimal}

echo "=========================================="
echo "🚀 Yocto Quick Build Script"
echo "=========================================="
echo ""
echo "Platform: $PLATFORM"
echo "Image: $IMAGE"
echo ""

# Check if in project directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Không tìm thấy docker-compose.yml"
    echo "   Hãy chạy script này từ thư mục yocto_multi_platform"
    exit 1
fi

# Step 1: Check Docker image
echo "📦 Bước 1: Kiểm tra Docker image..."
if ! docker images | grep -q "yocto-build-image"; then
    echo "   ⚠️  Docker image chưa có, đang build..."
    docker compose build
    echo "   ✅ Docker image đã được build"
else
    echo "   ✅ Docker image đã có sẵn"
fi
echo ""

# Step 2: Prepare directories
echo "📁 Bước 2: Chuẩn bị thư mục..."
if [ ! -d "build-$PLATFORM" ]; then
    ./scripts/host_prepare.sh
    echo "   ✅ Thư mục đã được tạo"
else
    echo "   ✅ Thư mục đã tồn tại"
fi
echo ""

# Step 3: Check layers
echo "📚 Bước 3: Kiểm tra Yocto layers..."
if [ ! -d "layers/poky" ]; then
    echo "   ⚠️  Layers chưa có, đang fetch..."
    HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/fetch_layers.sh"
    echo "   ✅ Layers đã được fetch"
else
    echo "   ✅ Layers đã có sẵn"
fi
echo ""

# Step 4: Setup build environment
echo "⚙️  Bước 4: Setup build environment..."
if [ ! -f "build-$PLATFORM/conf/local.conf" ]; then
    echo "   ⚠️  Build environment chưa setup, đang setup..."
    HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/setup_env.sh $PLATFORM developer"
    echo "   ✅ Build environment đã được setup"
else
    echo "   ✅ Build environment đã có sẵn"
fi
echo ""

# Step 5: Build
echo "🔨 Bước 5: Bắt đầu build..."
echo "   ⏱️  Build sẽ mất 2-4 giờ, vui lòng kiên nhẫn..."
echo "   📝 Log được lưu tại: logs/build-$PLATFORM-*.log"
echo ""

read -p "   Bạn có muốn tiếp tục build? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "   ❌ Build đã bị hủy"
    exit 0
fi

echo ""
echo "=========================================="
echo "🚀 Bắt đầu build..."
echo "=========================================="
echo ""

HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c "scripts/build.sh $PLATFORM developer $IMAGE"

BUILD_STATUS=$?

echo ""
echo "=========================================="
if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ Build thành công!"
    echo "=========================================="
    echo ""
    echo "📦 Image location:"
    echo "   build-$PLATFORM/tmp/deploy/images/"
    echo ""
    ls -lh build-$PLATFORM/tmp/deploy/images/*/ 2>/dev/null | head -10 || echo "   Đang kiểm tra..."
else
    echo "❌ Build thất bại!"
    echo "=========================================="
    echo ""
    echo "📝 Xem log để biết lỗi:"
    echo "   tail -50 logs/build-$PLATFORM-*.log"
    exit $BUILD_STATUS
fi

