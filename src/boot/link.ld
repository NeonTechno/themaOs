/* Thema OS — higher-half kernel layout.
   Limine maps the kernel at (phys load addr) + 0xFFFFFFFF80000000. */

OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

KERNEL_VBASE = 0xFFFFFFFF80000000;

SECTIONS
{
    . = KERNEL_VBASE + 0x100000;

    .text : ALIGN(4096) {
        KEEP(*(.limine_requests_start))
        KEEP(*(.limine_requests))
        KEEP(*(.limine_requests_end))
        *(.text .text.*)
    }

    .rodata : ALIGN(4096) { *(.rodata .rodata.*) }

    .data : ALIGN(4096) {
        *(.data .data.*)
    }

    .bss : ALIGN(4096) {
        *(COMMON)
        *(.bss .bss.*)
    }

    /DISCARD/ : {
        *(.eh_frame*) *(.note*) *(.comment*)
    }
}
