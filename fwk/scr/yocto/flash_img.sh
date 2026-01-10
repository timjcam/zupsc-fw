#!/bin/bash
#
# Flashes a xz-compressed SD card image to
#  1) a SD card on the local host
#  2) a SD card or eMMC on the target system
# and resizes the root partition on the storage medium to max size.
#
# The source can be
#  1) a image file on the local host
#  2) a image file on a remote HTTP server
#
# Usage:
#
# For local flashing:
#  ./flash_from_img.sh http://server.com/image.xz /dev/sdd
#  ./flash_from_img.sh image-file.xz /dev/sdd
# For remote flashing:
#  ./flash_from_img.sh http://server.com/image.xz zup-0552 /dev/mmcblk0
#  ./flash_from_img.sh image-file.xz zup-0552 /dev/mmcblk1

set -eux

resolve_parts () {
    DEVICE=${1}
    # Partition number to resize
    PARTNO="2"
    echo SD card device: ${DEVICE}
    if echo ${DEVICE} | grep -q mmcblk; then
        PARTPREFIX="${DEVICE}p"
    else
        PARTPREFIX="${DEVICE}"
    fi
    PARTDEV="${PARTPREFIX}${PARTNO}"
}

flash_local_device () {
    resolve_parts $1

    echo Writing ${FNAME} to ${DEVICE}...
    sudo umount ${PARTPREFIX}* || true
    xz -cd ${FNAME} | sudo dd of=${DEVICE} bs=1M iflag=fullblock conv=fsync status=progress

    echo Resizing partition ${PARTNO} on ${DEVICE}...
    sudo umount ${PARTPREFIX}* || true
    sudo parted ${DEVICE} resizepart ${PARTNO} 100%

    echo Running e2fsck for ${PARTDEV}...
    sudo umount ${PARTPREFIX}* || true
    sudo /sbin/e2fsck -fy ${PARTDEV}

    echo Resizing ${PARTDEV}...
    sudo umount ${PARTPREFIX}* || true
    sudo /sbin/resize2fs ${PARTDEV}

    echo Done
}

flash_remote_device () {
    resolve_parts $2
    REMOTE="root@$1"

    ssh ${REMOTE} "umount ${PARTPREFIX}* || true"

    cat ${FNAME} | ssh ${REMOTE} "xzcat | dd of=${DEVICE} bs=1M; sync"

    ssh ${REMOTE} "umount ${PARTPREFIX}* || true; parted ${DEVICE} resizepart ${PARTNO} 100% && umount ${PARTPREFIX}* || true; /sbin/e2fsck -fy ${PARTDEV} && umount ${PARTPREFIX}* || true; /sbin/resize2fs ${PARTDEV}; sync"
    echo Done
}

# 1) retrieve image file, if remote

if echo $1 | grep -Eq "^http.?://"; then
    echo "Downloading $1..."
    FNAME=/tmp/sd-image.xz
    curl -o $FNAME $1
else
    echo "Using local file $1"
    FNAME=$1
fi

ls -l $FNAME

if echo $2 | grep -Eq "^/dev/"; then
    echo "Flashing local device $2..."
    flash_local_device $2
else
    echo "Flashing $3 on remote host $2"
    flash_remote_device $2 $3
fi
