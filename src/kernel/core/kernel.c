#include "kernel/console.h"
#include "kernel/panic.h"
#include <limine.h>

/* Pin the Limine base protocol revision we were built against. */
__attribute__((used, section(".limine_requests")))
static volatile LIMINE_BASE_REVISION(2);

/* Memory map request — groundwork for the physical allocator (Milestone 2). */
__attribute__((used, section(".limine_requests")))
static volatile struct limine_memmap_request memmap_request = {
    .id = LIMINE_MEMMAP_REQUEST,
    .revision = 0,
};

static void print_banner(void) {
    console_puts("\n");
    console_puts("  ============================================\n");
    console_puts("   THEMA OS [DRP-capable kernel] v0.0.1\n");
    console_puts("   Milestone 1: boot + serial console\n");
    console_puts("  ============================================\n\n");
}

static void report_memory(void) {
    if (memmap_request.response == NULL) {
        console_puts("[memmap] no response from bootloader\n");
        return;
    }
    struct limine_memmap_response *mm = memmap_request.response;
    u64 usable = 0;
    for (u64 i = 0; i < mm->entry_count; i++) {
        struct limine_memmap_entry *e = mm->entries[i];
        console_puts("[memmap] base=");
        console_puthex(e->base);
        console_puts(" len=");
        console_puthex(e->length);
        console_puts(" type=");
        console_putdec((u64)e->type);
        console_putchar('\n');
        if (e->type == LIMINE_MEMMAP_USABLE) usable += e->length;
    }
    console_puts("[memmap] usable memory: ");
    console_putdec(usable / 1024 / 1024);
    console_puts(" MiB\n");
}

void kernel_main(void) {
    console_init();
    print_banner();

    if (LIMINE_BASE_REVISION_SUPPORTED == false) {
        console_puts("ERROR: unsupported Limine base revision.\n");
        panic_at(__FILE__, __LINE__, "boot protocol mismatch");
    }

    report_memory();

    console_puts("\n[kernel] Milestone 1 complete. Halting.\n");
    __asm__ volatile ("cli; hlt");
    __builtin_unreachable();
}
