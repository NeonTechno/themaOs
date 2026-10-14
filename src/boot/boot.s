; Thema OS — Limine protocol entry stub.
; The Limine protocol enters here in 64-bit long mode with:
;   - Paging enabled, higher half mapped (0xFFFFFFFF80000000 +)
;   - GDT loaded, interrupts off
; So all we do is set up a stack and call the C entry point.

section .text
bits 64
global _start
extern kernel_main

_start:
    mov rsp, stack_top    ; set up our own stack
    xor ebp, ebp          ; terminate frame pointers
    call kernel_main

.halt:
    cli
    hlt
    jmp .halt

section .bss
align 4096
resb 65536              ; 64 KiB boot stack
stack_top:
