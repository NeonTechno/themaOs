#!/usr/bin/env bash
# Build a bootable Thema OS ISO.
# Requires: xorriso, and the Limine binary release unpacked at tools/limine-bin/
set -euo pipefail
cd "$(dirname "$0")/.."

BUILD=build
ISO_ROOT=$BUILD/iso_root
LIMINE_BIN=tools/limine-bin

[ -f "$BUILD/kernel.elf" ] || { echo "Run 'make kernel' first." >&2; exit 1; }
[ -f "$LIMINE_BIN/limine-bios.sys" ] || {
    echo "Missing Limine binaries. Download the latest Limine release and" >&2
    echo "unpack limine-bios.sys, limine-bios-cd.bin, limine-uefi-cd.bin," >&2
    echo "and the 'limine' host tool into $LIMINE_BIN/" >&2
    exit 1
}

rm -rf "$ISO_ROOT"
mkdir -p "$ISO_ROOT/boot"
cp "$BUILD/kernel.elf" "$ISO_ROOT/boot/kernel.elf"
cp "$LIMINE_BIN/limine-bios.sys" "$ISO_ROOT/boot/limine-bios.sys"
cp "$LIMINE_BIN/limine-bios-cd.bin" "$ISO_ROOT/boot/limine-bios-cd.bin"
cp "$LIMINE_BIN/limine-uefi-cd.bin" "$ISO_ROOT/boot/limine-uefi-cd.bin"
cp src/boot/limine.cfg "$ISO_ROOT/boot/limine.cfg"

rm -f "$BUILD/thema.iso"
xorriso -as mkisofs -b boot/limine-bios-cd.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --efi-boot boot/limine-uefi-cd.bin \
    -efi-boot-part --efi-boot-image --protective-msdos-label \
    "$ISO_ROOT" -o "$BUILD/thema.iso"

"$LIMINE_BIN/limine" bios-install "$BUILD/thema.iso"
echo "ISO written to $BUILD/thema.iso"
