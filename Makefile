# Thema OS — top-level build
TARGET          := x86_64-elf
CC              := $(TARGET)-gcc
AS              := nasm
LD              := $(TARGET)-ld
CFLAGS          := -std=c17 -ffreestanding -nostdlib -mno-red-zone -Wall -Wextra \
                   -O2 -fno-stack-protector -fno-pic -mcmodel=kernel \
                   -fno-omit-frame-pointer
ASFLAGS         := -f elf64
LDFLAGS         := -nostdlib -static -z max-page-size=0x1000

BUILD           := build
KERNEL_ELF      := $(BUILD)/kernel.elf
ISO             := $(BUILD)/thema.iso
LIMINE_PROTO    := src/boot/limine-c-protocol

KERNEL_SRCS_C   := src/kernel/core/kernel.c \
                   src/kernel/core/console.c \
                   src/kernel/core/panic.c
KERNEL_SRCS_S   := src/boot/boot.s
KERNEL_OBJS     := $(patsubst src/%.c,$(BUILD)/obj/%.o,$(KERNEL_SRCS_C)) \
                   $(patsubst src/%.s,$(BUILD)/obj/%.o,$(KERNEL_SRCS_S))

CINCLUDES      := -Isrc/kernel/include -I$(LIMINE_PROTO)

.PHONY: all kernel iso run debug clean toolchain

all: kernel

kernel: $(KERNEL_ELF)

$(KERNEL_ELF): $(KERNEL_OBJS) src/boot/link.ld
	$(LD) $(LDFLAGS) -T src/boot/link.ld -o $@ $(KERNEL_OBJS)

$(BUILD)/obj/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CINCLUDES) -c $< -o $@

$(BUILD)/obj/%.o: src/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) $< -o $@

iso: $(KERNEL_ELF)
	./tools/build_iso.sh

run: iso
	./tools/run_qemu.sh

debug: iso
	qemu-system-x86_64 -cdrom $(ISO) -serial stdio -s -S &
	$(TARGET)-gdb $(KERNEL_ELF)

toolchain:
	@echo "See README.md — apt packages + rustup target x86_64-unknown-none"

clean:
	rm -rf $(BUILD)
