# tools/host-node — the zero-Rust host for Mentl modules

`mentl-host.mjs` runs `boot/mentl.wasm` (or any Mentl-emitted module) on
Node's own engine. The host is a SEAM, not an engine: it provides exactly
what the wheel's import list demands and nothing more:

- **WASI preview1** — Node's built-in `node:wasi`.
- **Shared memory** — `env.memory` created at the module's declared type
  (the boot imports 4 GB shared; Node allocates it fine).
- **`mentl_host`** — `wat_write` (stream sink) and `exec` (assemble the
  streamed WAT with wabt, instantiate the child in a fresh WASI context,
  run `_start`, return the exit code; a trap is 134).
- **`wasi/thread-spawn`** — via `worker_threads`; each thread is a fresh
  instance of the same module over the same shared memory, entered at
  `wasi_thread_start(tid, start_arg)`.
- **`-S tcplisten=`** — NOT YET IMPLEMENTED. `mentl session`/`space` refuse
  with a clear message (exit 2); the Rust runner still owns the socket seam.
  Building it needs a sync<->async bridge (the WASM runs in a worker,
  blocking on Atomics; the main thread drives the TCP server) — the named
  remainder, not a silent gap.

CLI-compatible with `tools/runner`'s `mentl-runner` for the flag subset the
mentl shim uses. `tools/wt-env.sh` selects this host automatically when the
Rust runner is not built (and `node` is present); `MENTL_HOST=node|runner`
forces one.

## Why two hosts

The compiler is one WebAssembly module. It runs on any host honoring the
seam contract above. The Rust runner is the reference (the gates are
measured against it); this host is the portable one — `tools/install.sh`
works with zero Rust toolchain. The fallback is explicit, never silent:
wt-env.sh prints which host it selected.
