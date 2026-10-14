#pragma once
#define PANIC(fmt, ...) panic_at(__FILE__, __LINE__, (fmt), ##__VA_ARGS__)
__attribute__((noreturn, format(printf, 3, 4)))
void panic_at(const char *file, int line, const char *fmt, ...);
