#!/bin/bash
# Shared helpers for platform/profile build paths.

resolve_product_conf_dir() {
    local platform="$1"
    local profile="$2"
    local base="/home/yocto/products/${platform}"

    if [ -f "${base}/${profile}/conf/local.conf" ]; then
        echo "${base}/${profile}/conf"
        return 0
    fi

    if [ -f "${base}/conf/local.conf" ]; then
        echo "${base}/conf"
        return 0
    fi

    return 1
}

resolve_build_dir() {
    local platform="$1"
    local profile="$2"

    if [ "$platform" = "rk3588" ] && [ "$profile" = "navonz_v1" ]; then
        echo "/home/yocto/build-rk3588-navonz_v1"
    else
        echo "/home/yocto/build-${platform}"
    fi
}

resolve_poky_dir() {
    local platform="$1"
    local profile="$2"

    if [ "$platform" = "rk3588" ] && [ "$profile" = "navonz_v1" ]; then
        echo "/home/yocto/layers-pin/poky"
    else
        echo "/home/yocto/layers/poky"
    fi
}

resolve_build_log_prefix() {
    local platform="$1"
    local profile="$2"

    if [ "$platform" = "rk3588" ] && [ "$profile" = "navonz_v1" ]; then
        echo "build-rk3588-navonz_v1"
    else
        echo "build-${platform}"
    fi
}
