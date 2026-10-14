# Thema OS

Security-first microkernel OS. Identity, capabilities, authorization, and
revocation are kernel primitives. See docs/ARCHITECTURE.md.

## Milestone 1 — boot + serial console

### 1. Install toolchain (Ubuntu/Debian)

```bash
sudo apt install -y build-essential gcc-x86_64-elf binutils-x86_64-elf \
    nasm qemu-system-x86 xorriso git make
```

### 2. Fetch Limine

```bash
git submodule add https://github.com/limine-bootloader/limine-c-protocol \
    src/boot/limine-c-protocol
```

Download the latest binary release from
https://github.com/limine-bootloader/limine/releases and unpack into
`tools/limine-bin/` (needs `limine-bios.sys`, `limine-bios-cd.bin`,
`limine-uefi-cd.bin`, and the `limine` host tool).

### 3. Build and run

```bash
make kernel    # build kernel.elf
make iso       # build bootable ISO
make run       # boot in QEMU, serial on stdout
```

Expected output starts with:

```
THEMA OS [DRP-capable kernel] v0.0.1
```

### Rust (from Milestone 2 on)

```bash
rustup target add x86_64-unknown-none
rustup component add rust-src
```

## Verification checklist

- [ ] `x86_64-elf-gcc --version`, `nasm -v`, `xorriso -version`, `qemu-system-x86_64 --version` all succeed
- [ ] `make kernel` produces `build/kernel.elf` with no warnings
- [ ] `make iso` produces `build/thema.iso` and `limine bios-install` reports success
- [ ] `make run` prints the THEMA OS banner and the memory map over serial
- [ ] Kernel halts cleanly; no triple fault

## Roadmap

1. Physical page allocator over the Limine memory map
2. Kernel heap (slab) + capability_t allocation
3. Capability hash table + revocation bitmap
4. First syscall path: cap_grant / cap_check / cap_revoke
