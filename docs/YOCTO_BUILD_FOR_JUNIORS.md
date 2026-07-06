# Yocto Build & Device Tree — Hướng dẫn cho Junior

Tài liệu này giải thích **hệ thống build Yocto hoạt động thế nào** trong project `yocto_multi_platform`, và **cách thay đổi Device Tree** cho board Navonz (NanoPC-T6 / RK3588).

Đọc xong, bạn nên hiểu:
- Yocto build ra image OS từ đâu, qua những bước nào
- Layer, recipe, machine, image nghĩa là gì
- Device Tree là gì và nằm ở đâu trong build Navonz
- Profile `developer` vs `navonz_v1` khác nhau chỗ nào
- Làm sao sửa DT an toàn

---

## 1. Yocto là gì? (1 phút)

**Yocto** không phải một bản Linux có sẵn. Nó là **công cụ build** giúp bạn tự ráp một bản Linux tùy chỉnh cho phần cứng cụ thể:

```
Source code (kernel, driver, app)
        +
Cấu hình (board nào, cài package gì)
        ↓
    BitBake (engine build)
        ↓
Image flash được (.wic) → SD card / eMMC → board boot
```

Trong project này, board mục tiêu là **NanoPC-T6** (SoC Rockchip **RK3588**), gọi tắt là **Navonz**.

---

## 2. Các khái niệm cốt lõi

### 2.1 Layer (lớp)

Layer = một thư mục chứa **recipe + config** cho một mảng việc.

| Layer | Vai trò |
|-------|---------|
| `poky/meta` | Core Yocto, BitBake, recipe cơ bản |
| `poky/meta-poky` | Distro "poky" mặc định |
| `meta-rockchip` | Hỗ trợ SoC Rockchip (RK3588, U-Boot, firmware) |
| `meta-arm` | Toolchain ARM |
| `meta-openembedded` | Thêm package (python, multimedia...) |
| `products/rk3588` | **Custom layer của team** (chỉ profile `developer`) |

Layer được liệt kê trong `conf/bblayers.conf`. BitBake chỉ nhìn các layer trong file này.

### 2.2 Recipe (`.bb` / `.bbappend`)

Recipe = **công thức build** một package.

Ví dụ:
- `core-image-minimal.bb` → ráp image Linux tối thiểu
- `linux-yocto_%.bb` → build kernel
- `u-boot-rockchip_%.bb` → build U-Boot

File `.bbappend` = **patch nhỏ** lên recipe gốc, không sửa trực tiếp layer upstream.

Ví dụ trong project:
```
products/rk3588/recipes-kernel/linux/linux-yocto_%.bbappend
```
→ báo kernel recipe biết hỗ trợ machine `nanopc-t6`.

### 2.3 Machine

Machine = **định nghĩa phần cứng** (CPU, DTB, U-Boot config, feature...).

File quan trọng:
```
meta-rockchip/conf/machine/nanopc-t6.conf
```

Trong `conf/local.conf` bạn chọn:
```
MACHINE ??= "nanopc-t6"
```

### 2.4 Image

Image = **sản phẩm cuối** cần build, ví dụ `core-image-minimal`.

Output nằm tại:
```
build-rk3588/tmp/deploy/images/nanopc-t6/           # developer
build-rk3588-navonz_v1/tmp/deploy/images/nanopc-t6/ # navonz_v1
```

File quan trọng nhất: `core-image-minimal-nanopc-t6.wic` — flash vào thẻ nhớ.

### 2.5 BitBake

**BitBake** = make system của Yocto. Nó:
1. Đọc recipe + config
2. Tính dependency graph (task A phải xong trước task B)
3. Chạy từng task: fetch → unpack → patch → configure → compile → install → package → rootfs → image

Một build có thể có **hàng nghìn task** (ví dụ ~3700 task cho Navonz).

---

## 3. Luồng build trong project này

### 3.1 Sơ đồ tổng quan

```
┌─────────────────────────────────────────────────────────────┐
│  Host (máy dev)                                             │
│  docker compose run yocto ...                               │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  Container yocto-build-image                                │
│                                                             │
│  1. fetch_layers.sh / fetch_layers_pin.sh  → clone layers   │
│  2. setup_env.sh rk3588 <profile>          → copy conf      │
│  3. build.sh rk3588 <profile> <image>      → bitbake       │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌────────────────┴────────────────┐
          ▼                                 ▼
   layers/ (kirkstone)              layers-pin/ (SHA pin)
   + products/rk3588                 không custom layer
   profile: developer                profile: navonz_v1
          │                                 │
          ▼                                 ▼
   build-rk3588/                  build-rk3588-navonz_v1/
          │                                 │
          └────────────────┬────────────────┘
                           ▼
              downloads/ + sstate-cache/  (dùng chung, tiết kiệm thời gian)
                           ▼
                    .wic image output
```

### 3.2 Hai profile Navonz

| | `developer` | `navonz_v1` |
|---|---|---|
| **Mục đích** | Phát triển, tùy chỉnh | Snapshot đã verify, reproducible |
| **Layers** | `layers/` branch kirkstone | `layers-pin/` commit pin cố định |
| **Custom layer** | Có `products/rk3588` | Không |
| **Machine config** | Override trong `products/rk3588/conf/machine/nanopc-t6.conf` | Gốc từ `meta-rockchip` |
| **Build dir** | `build-rk3588/` | `build-rk3588-navonz_v1/` |

**Lệnh build:**
```bash
# Custom
docker compose run --rm yocto bash -c \
  "scripts/setup_env.sh rk3588 developer && \
   scripts/build.sh rk3588 developer core-image-minimal"

# Snapshot gốc
docker compose run --rm yocto bash -c \
  "scripts/fetch_layers_pin.sh && \
   scripts/setup_env.sh rk3588 navonz_v1 && \
   scripts/build.sh rk3588 navonz_v1 core-image-minimal"
```

### 3.3 Các thư mục quan trọng

| Thư mục | Chứa gì |
|---------|---------|
| `layers/` | Source layer kirkstone (dùng chung nhiều board) |
| `layers-pin/` | Layer pin cho navonz_v1 |
| `downloads/` | Source tarball git fetch về (dùng chung) |
| `sstate-cache/` | Cache task đã build (dùng chung) |
| `build-*/tmp/work/` | Source đang compile (tạm) |
| `build-*/tmp/deploy/images/` | **Output cuối** |
| `logs/` | Log bitbake |

---

## 4. BitBake chạy những gì? (chi tiết hơn)

Khi bạn gõ `bitbake core-image-minimal`, chuỗi chính:

```
1. Parse recipes     → đọc tất cả .bb trong bblayers
2. Resolve deps      → kernel cần gcc-cross, rootfs cần busybox...
3. Fetch             → tải source vào downloads/
4. Compile toolchain → gcc cho aarch64 (cross-compile)
5. Build kernel      → linux-yocto + device tree → fitImage
6. Build bootloader  → U-Boot, TF-A (bl31), ddr blob...
7. Build packages    → hàng trăm .rpm/.ipk
8. Assemble rootfs   → gom package thành filesystem
9. Create image      → wic (partition layout + boot artifacts)
```

**Sstate cache:** Nếu task đã chạy trước đó (cùng input), BitBake **bỏ qua** và copy từ cache → build lần 2 nhanh hơn rất nhiều.

---

## 5. Device Tree là gì?

### 5.1 Khái niệm

**Device Tree (DT)** = file mô tả phần cứng cho kernel Linux:
- CPU cores, clock
- GPIO, I2C, SPI, UART
- Ethernet, WiFi, HDMI
- Pin mux, regulator, sensor...

Kernel đọc DT lúc boot để biết **driver nào bind vào hardware nào**.

```
Source:  rk3588-nanopc-t6.dts   (human-readable, text)
           ↓ dtc (device tree compiler)
Binary:  rk3588-nanopc-t6.dtb   (bootloader/kernel đọc file này)
```

### 5.2 DT nằm ở đâu trong build Navonz?

**Profile `navonz_v1`** (dùng config gốc meta-rockchip):

```9:15:layers-pin/meta-rockchip/conf/machine/nanopc-t6.conf
KERNEL_DEVICETREE = " \
    rockchip/rk3588-nanopc-t6.dtb \
    rockchip/rk3588-nanopc-t6-lts.dtb \
"
UBOOT_MACHINE = "nanopc-t6-rk3588_defconfig"
```

→ Build 2 file DTB từ kernel source, đóng gói vào **fitImage** (Rockchip dùng FIT format gộp kernel + DTB).

**Profile `developer`** (custom layer override):

```7:17:products/rk3588/conf/machine/nanopc-t6.conf
# Set to empty string for fitImage (device tree is included in fitImage)
KERNEL_DEVICETREE = ""
UBOOT_MACHINE ?= "evb-rk3568_defconfig"
```

→ Đây là **workaround tạm** khi team build kirkstone; DTB có thể không đúng chuẩn như bản gốc. **Muốn DT đúng → dùng `navonz_v1` hoặc sửa lại developer config.**

### 5.3 Artifact sau build

Trong `tmp/deploy/images/nanopc-t6/`:

| File | Ý nghĩa |
|------|---------|
| `fitImage-nanopc-t6.bin` | Kernel + DTB (Rockchip boot) |
| `idbloader.img` | Boot stage 1 |
| `u-boot.itb` | U-Boot FIT image |
| `bl31-rk3588.elf` | ARM Trusted Firmware |
| `ddr-rk3588.bin` | DDR initialization |
| `core-image-minimal-nanopc-t6.wic` | **Full disk image** (flash cái này) |

---

## 6. Device Tree Navonz thay đổi được không?

**Có.** Nhưng có nhiều cách, mức độ khó khác nhau.

### Cách 1: Đổi DTB trong machine config (dễ nhất)

Nếu kernel đã có sẵn file `.dts` khác (cùng SoC RK3588):

```bitbake
# products/rk3588/conf/machine/nanopc-t6.conf  (developer)
KERNEL_DEVICETREE = "rockchip/rk3588-nanopc-t6.dtb"
```

Hoặc build cả 2 biến thể (như bản gốc):
```bitbake
KERNEL_DEVICETREE = " \
    rockchip/rk3588-nanopc-t6.dtb \
    rockchip/rk3588-nanopc-t6-lts.dtb \
"
```

Sau đó:
```bash
scripts/setup_env.sh rk3588 developer
scripts/build.sh rk3588 developer core-image-minimal
```

Chỉ rebuild kernel + image (nhanh hơn full build nếu sstate còn):
```bash
bitbake linux-yocto -c cleansstate   # trong build env
bitbake core-image-minimal
```

### Cách 2: Patch file `.dts` trong kernel (phổ biến nhất)

Khi cần sửa pin GPIO, thêm node I2C sensor, tắt một peripheral...

**Bước:**
1. Tìm file dts trong kernel source sau khi fetch:
   ```
   build-*/tmp/work/*/linux-yocto/*/git/arch/arm64/boot/dts/rockchip/rk3588-nanopc-t6.dts
   ```
2. Tạo patch hoặc `.bbappend` copy dts đã sửa
3. Đặt trong custom layer:
   ```
   products/rk3588/recipes-kernel/linux/linux-yocto/
   ├── nanopc-t6.dts          # file sửa
   └── linux-yocto_%.bbappend # chỉ dẫn copy vào kernel tree
   ```

Ví dụ `bbappend` (minh họa):
```bitbake
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append:nanopc-t6 = " file://rk3588-nanopc-t6-custom.dts"
do_configure:append:nanopc-t6() {
    cp ${WORKDIR}/rk3588-nanopc-t6-custom.dts \
       ${S}/arch/arm64/boot/dts/rockchip/rk3588-nanopc-t6.dts
}
```

> **Lưu ý:** Cách này chỉ hoạt động với profile `developer` (có custom layer). Profile `navonz_v1` không load `products/rk3588`.

### Cách 3: Device Tree Overlay (DTO) — runtime

Thay đổi DT **không cần rebuild** bằng overlay (nếu kernel + bootloader hỗ trợ):

```bash
# Trên board đang chạy
ls /sys/kernel/config/device-tree/overlays/
```

Phù hợp khi test nhanh, không phù hợp production image.

### Cách 4: Đổi kernel version / branch

Đổi `PREFERRED_VERSION` hoặc `SRC_URI` trong recipe kernel → DTB mới có thể xuất hiện hoặc thay đổi format. **Rủi ro cao**, cần senior review.

---

## 7. Quy tắc an toàn khi sửa DT

1. **Luôn backup** image `.wic` đang chạy tốt trước khi thử bản mới
2. **Sửa DT trong `developer`**, verify boot OK, rồi mới cân nhắc đưa vào production
3. **Không sửa trực tiếp** file trong `layers/` hoặc `layers-pin/` — dùng custom layer hoặc `.bbappend`
4. **DT sai = board không boot** (màn hình đen, không serial) — chuẩn bị UART debug
5. Serial console Navonz: baud **1500000**, device **ttyS2** (theo meta-rockchip defaults)

---

## 8. Debug khi board không boot sau đổi DT

```bash
# 1. Kiểm tra fitImage có chứa fdt không
dumpimage -l fitImage-nanopc-t6.bin

# 2. Decompile dtb để đọc
dtc -I dtb -O dts -o out.dts rk3588-nanopc-t6.dtb

# 3. Xem log build kernel
less build-*/tmp/work/*/linux-yocto/*/temp/log.do_compile

# 4. So sánh DTB giữa developer vs navonz_v1
diff <(dtc -I dtb -O dts dev.dtb) <(dtc -I dtb -O dts v1.dtb)
```

---

## 9. Bài tập cho Junior

### Bài 1 — Quan sát (không sửa gì)
- [ ] Mở `products/rk3588/developer/conf/bblayers.conf`, liệt kê các layer
- [ ] So sánh với `products/rk3588/navonz_v1/conf/bblayers.conf`
- [ ] Tìm `nanopc-t6.conf` trong `layers-pin/meta-rockchip/conf/machine/`
- [ ] Liệt kê file trong `build-rk3588/tmp/deploy/images/nanopc-t6/`

### Bài 2 — Đọc log build
- [ ] Mở log `logs/build-rk3588-navonz_v1-*.log`
- [ ] Tìm dòng `Build Configuration:` — ghi MACHINE, DISTRO_VERSION
- [ ] Tìm `Tasks Summary` — bao nhiêu task, có failed không?

### Bài 3 — Trace một package
Chọn `busybox`:
- [ ] Tìm recipe: `find layers* -name 'busybox*.bb'`
- [ ] Trong log, tìm `busybox` đang ở task nào
- [ ] Giải thích: busybox nằm trong rootfs vì ai depend?

### Bài 4 — DT (có giám sát senior)
- [ ] Decompile DTB từ image build thành công
- [ ] Tìm node `uart`, `ethernet`, `hdmi` trong file `.dts`
- [ ] Đề xuất 1 thay đổi nhỏ (ví dụ đổi status LED gpio) — **chưa apply**, chỉ viết patch plan

---

## 10. Từ điển nhanh

| Thuật ngữ | Nghĩa ngắn |
|-----------|------------|
| BitBake | Build engine của Yocto |
| Layer | Bộ recipe + config |
| Recipe (.bb) | Công thức build 1 package |
| bbappend | Patch nhỏ lên recipe gốc |
| Machine | Định nghĩa board/phần cứng |
| Image | OS image output (.wic) |
| DT / DTS / DTB | Device tree source / binary |
| fitImage | Format gộp kernel + DTB (Rockchip) |
| sstate | Cache task đã build |
| DL_DIR | Thư mục chứa source đã tải |
| WIC | Disk image format (partition table + content) |
| Cross-compile | Build trên x86, chạy trên ARM |

---

## 11. Tài liệu tham khảo thêm

- [Yocto Project Overview](https://docs.yoctoproject.org/overview.html)
- [Yocto Kernel Dev](https://docs.yoctoproject.org/kernel-dev/index.html)
- [Device Tree Specification](https://www.devicetree.org/specifications/)
- Trong repo: `products/rk3588/README.md`, `NANOPC_T6_REFERENCE.md`

---

*Cập nhật: 2026-07 — project yocto_multi_platform, board NanoPC-T6 (Navonz / RK3588)*
