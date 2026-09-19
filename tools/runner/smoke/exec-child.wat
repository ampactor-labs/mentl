;; exec smoke — the Process seam (Hβ.ops.runner-is-the-process-handler):
;; the guest streams a child module's WAT through mentl_host.wat_write,
;; then mentl_host.exec assembles + instantiates + runs it and returns the
;; child's exit as a VALUE. Two children: the first proc_exits 42, the
;; second traps (unreachable) and must answer 134, the code the micro
;; battery banks for a trap. Expected exit: 42 when both answers hold;
;; otherwise the first child's own answer, so a wrong decode is legible.
;; RED against a runner without the seam: instantiation refuses the
;; unknown import (measured 2026-09-17 before the seam landed).
(module
  (import "mentl_host" "wat_write" (func $wat_write (param i32 i32)))
  (import "mentl_host" "exec" (func $exec (param i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))
  (memory (export "memory") 1 1 shared)
  ;; child 1: exits 42
  (data (i32.const 1024) "(module (import \"wasi_snapshot_preview1\" \"proc_exit\" (func $pe (param i32))) (memory (export \"memory\") 1 1 shared) (func (export \"_start\") (call $pe (i32.const 42))))")
  ;; child 2: traps
  (data (i32.const 2048) "(module (memory (export \"memory\") 1 1 shared) (func (export \"_start\") (unreachable)))")
  ;; argv: NUL-joined, argv[0] only
  (data (i32.const 3072) "child\00")
  (func $start (local $a i32) (local $b i32)
    (call $wat_write (i32.const 1024) (i32.const 166))
    (local.set $a (call $exec (i32.const 3072) (i32.const 6)))
    (call $wat_write (i32.const 2048) (i32.const 85))
    (local.set $b (call $exec (i32.const 3072) (i32.const 6)))
    (if (i32.and (i32.eq (local.get $a) (i32.const 42)) (i32.eq (local.get $b) (i32.const 134)))
      (then (call $proc_exit (i32.const 42)))
      (else (call $proc_exit (local.get $a))))
    (unreachable))
  (export "_start" (func $start)))
