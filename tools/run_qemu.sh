#!/usr/bin/env bash
# Run Thema OS in QEMU with serial output on stdout.
set -euo pipefail
cd "$(dirname "$0")/.."
exec qemu-system-x86_64 \
    -M q35 -m 512M -cdrom build/thema.iso \
    -serial stdio -no-reboot -no-shutdown
