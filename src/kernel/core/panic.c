#include "kernel/console.h"
#include "kernel/panic.h"
#include <stdarg.h>

__attribute__((noreturn, format(printf, 3, 4)))
void panic_at(const char *file, int line, const char *fmt, ...) {
    console_puts("\n!!! KERNEL PANIC at ");
    console_puts(file);
    console_putchar(':');
    console_putdec((u64)line);
    console_puts(" - ");

    va_list ap;
    va_start(ap, fmt);
    /* Bounded formatting: no printf engine yet, print the raw message. */
    console_puts(fmt);
    va_end(ap);

    console_puts("\nSystem halted.\n");
    __asm__ volatile ("cli; hlt");
    __builtin_unreachable();
}
