#pragma once
#include "kernel/types.h"

/* Serial console (COM1, 0x3F8). The only output channel in Milestone 1. */
void console_init(void);
void console_putchar(char c);
void console_puts(const char *s);
void console_putdec(u64 v);
void console_puthex(u64 v);
