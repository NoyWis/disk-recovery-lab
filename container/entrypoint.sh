#!/bin/bash
set -e

DISK_DIR=/disks
DISK_SIZE=256M
NAMES=(a b c)   # -> sda, sdb, sdc

mkdir -p "$DISK_DIR"

for i in "${!NAMES[@]}"; do
    n=$((i + 1))
    img="$DISK_DIR/disk${n}.img"
    dev="sd${NAMES[$i]}"

    if [ ! -f "$img" ]; then
        echo "[entrypoint] creating $img ($DISK_SIZE)"
        truncate -s "$DISK_SIZE" "$img"
    fi

    # reuse an already-attached loop device for this file (container restart),
    # otherwise attach a fresh one
    loopdev=$(losetup -j "$img" | cut -d: -f1)
    if [ -z "$loopdev" ]; then
        loopdev=$(losetup -f --show "$img")
        echo "[entrypoint] attached $img -> $loopdev"
    else
        echo "[entrypoint] $img already attached -> $loopdev"
    fi

    ln -sf "$loopdev" "/dev/${dev}"
    echo "[entrypoint] /dev/${dev} -> $loopdev"
done

lsblk 2>/dev/null || true

# make sure ssh host keys exist
ssh-keygen -A >/dev/null 2>&1 || true

echo "[entrypoint] starting sshd"
exec /usr/sbin/sshd -D -e
