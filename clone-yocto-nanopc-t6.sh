#!/bin/bash
# ============================================================
# clone-yocto-nanopc-t6.sh
# Clone đúng các layer Yocto (đã pin commit, đã kiểm chứng build
# thành công) và build core-image-minimal cho NanoPC-T6 (RK3588).
#
# Chạy: bash clone-yocto-nanopc-t6.sh [thư_mục_đích]
# ============================================================

set -e

WORKDIR="${1:-$HOME/yocto-nanopc-t6}"
MACHINE="nanopc-t6"

POKY_URL="https://git.yoctoproject.org/git/poky"
POKY_SHA="1dec53b350d7d2edcc880f640b1cb2fd31ff7f0b"

META_OE_URL="https://git.openembedded.org/meta-openembedded"
META_OE_SHA="fd6a9a2b30fab61c3761b42110b37512756f3525"

META_ARM_URL="https://git.yoctoproject.org/meta-arm"
META_ARM_SHA="a3a2c49b2149606f314b2ee0aeba7d6becd12545"

META_ROCKCHIP_URL="https://git.yoctoproject.org/meta-rockchip"
META_ROCKCHIP_SHA="4fdc16878efb6e1af933d65da64bfb1a4dff1735"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✔]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✘]${NC} $*"; exit 1; }

# ============================================================
# Kiểm tra & cài gói phụ thuộc (Ubuntu/Debian, cần sudo)
# ============================================================
REQUIRED_PKGS=(gawk wget git diffstat unzip texinfo gcc build-essential
    chrpath socat cpio python3 python3-pip python3-pexpect xz-utils
    debianutils iputils-ping python3-git python3-jinja2 python3-subunit
    mesa-common-dev zstd liblz4-tool file locales libacl1-dev)

missing_pkgs=()
for pkg in "${REQUIRED_PKGS[@]}"; do
    dpkg -s "$pkg" >/dev/null 2>&1 || missing_pkgs+=("$pkg")
done

if [ "${#missing_pkgs[@]}" -gt 0 ]; then
    warn "Thiếu gói: ${missing_pkgs[*]}"
    log "Cài đặt (cần sudo)..."
    sudo apt-get update
    sudo apt-get install -y "${missing_pkgs[@]}"
fi

command -v git &>/dev/null || err "Cần cài git trước khi chạy script này"

# ============================================================
# Clone layer, checkout đúng commit đã pin
# ============================================================
clone_pin() {
    local url="$1" sha="$2" dest="$3"

    if [ -d "$dest/.git" ]; then
        warn "$dest đã tồn tại → bỏ qua clone (xóa thư mục nếu muốn clone lại)"
        return
    fi

    log "Cloning $dest @ ${sha:0:12} ..."
    git init -q "$dest"
    git -C "$dest" remote add origin "$url"
    git -C "$dest" fetch --depth=1 origin "$sha" \
        || err "Fetch thất bại: $dest ($url @ $sha)"
    git -C "$dest" checkout -q FETCH_HEAD
    log "$dest OK"
}

mkdir -p "$WORKDIR"
cd "$WORKDIR"
log "Thư mục làm việc: $WORKDIR"
echo ""

clone_pin "$POKY_URL"           "$POKY_SHA"           "poky"
clone_pin "$META_OE_URL"        "$META_OE_SHA"         "meta-openembedded"
clone_pin "$META_ARM_URL"       "$META_ARM_SHA"        "meta-arm"
clone_pin "$META_ROCKCHIP_URL"  "$META_ROCKCHIP_SHA"   "meta-rockchip"

# ============================================================
# Khởi tạo build environment
# ============================================================
echo ""
log "Khởi tạo build environment..."
source poky/oe-init-build-env build

cat > conf/bblayers.conf <<EOF
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \\
  $WORKDIR/poky/meta \\
  $WORKDIR/poky/meta-poky \\
  $WORKDIR/poky/meta-yocto-bsp \\
  $WORKDIR/meta-arm/meta-arm \\
  $WORKDIR/meta-arm/meta-arm-toolchain \\
  $WORKDIR/meta-rockchip \\
  "
EOF

if ! grep -q "^MACHINE = \"$MACHINE\"" conf/local.conf; then
    echo "MACHINE = \"$MACHINE\"" >> conf/local.conf
fi

log "bblayers.conf và local.conf (MACHINE=$MACHINE) đã sẵn sàng"

# ============================================================
# Build
# ============================================================
echo ""
log "Bắt đầu build core-image-minimal (sẽ mất nhiều giờ)..."
bitbake core-image-minimal

echo ""
log "Build hoàn tất! Image nằm tại:"
echo "  $WORKDIR/build/tmp/deploy/images/$MACHINE/"
echo ""
echo "Flash vào SD card/eMMC:"
echo "  sudo dd if=$WORKDIR/build/tmp/deploy/images/$MACHINE/core-image-minimal-$MACHINE.rootfs.wic of=/dev/sdX bs=4M status=progress conv=fsync"
echo "  sync"
