#!/bin/bash
# Convenience wrapper: fetch pin layers (if needed), setup, and build rk3588.
set -e

PROFILE="${1:-developer}"
IMAGE="${2:-core-image-minimal}"

case "$PROFILE" in
    developer|production|navonz_v1) ;;
    *)
        echo "Usage: $0 [developer|navonz_v1] [image]"
        echo "  developer  — kirkstone layers + custom products/rk3588 (default)"
        echo "  navonz_v1  — pinned snapshot layers in layers-pin/"
        exit 1
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$PROFILE" = "navonz_v1" ]; then
    echo ">>> navonz_v1: ensuring pinned layers..."
    "${SCRIPT_DIR}/fetch_layers_pin.sh"
fi

"${SCRIPT_DIR}/setup_env.sh" rk3588 "$PROFILE"
"${SCRIPT_DIR}/build.sh" rk3588 "$PROFILE" "$IMAGE"
