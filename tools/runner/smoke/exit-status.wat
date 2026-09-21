;; exit-status smoke — proc_exit is the runner's, not the adapter's. A guest
;; whose answer is 134 (the exec seam handing a trapped child's status
;; straight through as `mentl run x`'s own exit) must exit 134: the process
;; exit is the guest's value, truncated to a byte by the OS and by nothing
;; else. Expected exit: 134.
;; RED against the p1 adapter's own proc_exit: "exit with invalid exit status
;; outside of [0..126)" and exit 1 (measured 2026-09-17, the first `mentl run`
;; of tests/micros/mn-oob-traps.mn through the wheel).
(module
  (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))
  (memory (export "memory") 1 1 shared)
  (func $start
    (call $proc_exit (i32.const 134))
    (unreachable))
  (export "_start" (func $start)))
