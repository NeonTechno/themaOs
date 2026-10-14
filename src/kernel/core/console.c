#include "kernel/console.h"
#include "kernel/panic.h"

#define COM1 0x3F8

static inline void outb(u16 port, u8 val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline u8 inb(u16 port) {
    u8 ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

/* T3 mitigation: no dynamic allocation, fixed state, no recursion. */
void console_init(void) {
    outb(COM1 + 1, 0x00);   /* disable interrupts */
    outb(COM1 + 3, 0x80);   /* DLAB on */
    outb(COM1 + 0, 0x03);   /* 38400 baud */
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x03);   /* 8N1, DLAB off */
    outb(COM1 + 2, 0xC7);   /* FIFO, clear, 14-byte threshold */
    outb(COM1 + 4, 0x0B);   /* DTR + RTS + OUT2 */
}

static void wait_transmit(void) {
    /* Bounded wait — cannot spin forever on broken HW. */
    for (int i = 0; i < 100000; i++) {
        if (inb(COM1 + 5) & 0x20) return;   /* THR empty */
    }
    /* Give up silently; a wedged serial line must not hang the kernel. */
}

void console_putchar(char c) {
    wait_transmit();
    outb(COM1, (u8)c);
}

void console_puts(const char *s) {
    while (*s) console_putchar(*s++);
}

void console_putdec(u64 v) {
    char buf[21];               /* enough for 2^64-1 */
    int i = 21;
    if (v == 0) { console_putchar('0'); return; }
    while (v) { buf[--i] = '0' + (v % 10); v /= 10; }
    console_puts(&buf[i]);
}

void console_puthex(u64 v) {
    static const char h[] = "0123456789ABCDEF";
    console_puts("0x");
    for (int shift = 60; shift >= 0; shift -= 4)
        console_putchar(h[(v >> shift) & 0xF]);
}
