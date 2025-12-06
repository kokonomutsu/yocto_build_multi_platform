#!/bin/bash
# Start build in background with logging

set -e

if [ $# -lt 3 ]; then
    echo "Usage: $0 <platform> <profile> <image>"
    echo "  platform: s905x3, rpi4, or rpi0w"
    echo "  profile: developer or production"
    echo "  image: core-image-minimal, core-image-base, etc."
    exit 1
fi

PLATFORM=$1
PROFILE=$2
IMAGE=$3
BASE_DIR=/home/picopiece/yocto_multi_platform
LOG_DIR=$BASE_DIR/logs
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE=${LOG_DIR}/build-${PLATFORM}-${IMAGE}-${TIMESTAMP}.log

mkdir -p ${LOG_DIR}

echo ">>> Starting background build: ${PLATFORM} - ${IMAGE}"
echo ">>> Log file: ${LOG_FILE}"
echo ">>> Build will run in background"
echo ""

# Start build in background
cd ${BASE_DIR}
nohup bash -c "HOST_UID=1000 HOST_GID=1000 docker compose run --rm yocto bash -c 'scripts/build.sh ${PLATFORM} ${PROFILE} ${IMAGE}'" > ${LOG_FILE} 2>&1 &

BUILD_PID=$!
echo ">>> Build started with PID: ${BUILD_PID}"
echo ">>> Monitor with: tail -f ${LOG_FILE}"
echo ">>> Check status with: ./scripts/check_build_status.sh"
echo ""
echo ">>> To stop build: kill ${BUILD_PID}"

