# Thema OS — Architecture

## Core Thesis

Thema OS treats identity, capabilities, authorization, and revocation as
first-class kernel primitives, enforced at the hardware isolation boundary.
It is a microkernel-based system whose TCB consists solely of: memory
isolation, capability enforcement, process separation, and minimal IPC.
All other services (filesystems, networking, DRP client, AI runtime) run as
unprivileged user-space components with explicitly granted capabilities.

## Key Innovations

1. Capability tokens as kernel objects — non-forgeable, scoped, time-bound, revocable
2. Identity separation — human, device, process, application, service, AI agent identities are distinct and non-inheriting
3. Credential broker pattern — applications request operations, never receive private keys
4. DRP as verification oracle — network provides attestations; local kernel enforces policy
5. AI agent containment — process-level isolation with per-task capability grants

## Design Decisions

- Modified microkernel (L4/Fiasco-style): kernel handles memory, capabilities,
  IPC, interrupts; everything else is a user-space service.
- Bootloader: Limine, native boot protocol (NOT multiboot2). Limine enters the
  kernel in 64-bit long mode with paging and the higher-half mapping already
  set up.
- Languages: x86_64 assembly (boot stub), C17 (kernel core, drivers), Rust
  (capability engine, user-space services). Rust freestanding target is
  `x86_64-unknown-none` (not `-elf`).
- Serial console first; no network or filesystem in Milestone 1.
- DRP as oracle, never a runtime dependency: never block boot on DRP
  availability, never trust unsigned responses, verify signatures locally,
  cache with TTL, fall back to local-only policy when offline.

## Capability Model (summary)

- Deny by default; kernel-only minting; scoped (resource + operation + constraints)
- Time-bound (`expires_at`, monotonic clock) and immediately revocable
  (kernel-checked revocation bitmap)
- Stored in kernel memory; user-space holds only 64-bit `cap_id_t` handles
- Enforced at syscalls, page faults, IPC, and device MMIO access

## Threat Model (Milestone 1)

Assets: kernel integrity, memory isolation, capability state, boot chain.
Actors: malicious local user, compromised driver, faulty hardware, network
attacker, malicious AI agent.

| ID | Threat | Severity | Mitigation |
|----|--------|----------|------------|
| T1 | Stack overflow in boot code | Critical | No recursion, bounded stacks |
| T2 | Invalid memory map processing | Critical | Bounds-checked iteration of Limine memmap |
| T3 | Serial buffer overflow | High | No dynamic allocation in early boot |
| T4 | Kernel code exec from data | Critical | Limine-provided mapping; NX enforced in Milestone 2 paging |
| T5 | Physical memory exhaustion | Medium | Limit early allocations |
| T6 | Interrupt storm | Medium | Interrupts remain masked until handler ready |
| T7 | Info leak via serial | Low | Accepted for prototype |

## Milestones

- M1 (this repo state): boot via Limine, serial console, memory map report
- M2: physical allocator, kernel heap, capability engine, first syscalls
- M3: processes, scheduler, IPC
- M4: user-space services (fs, net, cred broker, DRP client, AI runtime)
