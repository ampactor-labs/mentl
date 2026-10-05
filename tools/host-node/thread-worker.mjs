// thread-worker.mjs — the wasi-thread-spawn worker.
//
// A spawned wasi thread: a fresh instance of the SAME module in this worker,
// over the SAME shared memory, entered at wasi_thread_start(tid, start_arg).
// wasi-threads semantics: proc_exit or a trap on any thread ends the process.

import { WASI } from 'node:wasi';
import { workerData } from 'node:worker_threads';

const { moduleBytes, memory, tid, startArg, spec } = workerData;

const wasi = new WASI({
  version: 'preview1',
  args: spec.argv,
  env: Object.fromEntries(spec.envs),
  preopens: Object.fromEntries(spec.preopens.map(([h, g]) => [g, h])),
  returnOnExit: true,
});

// Rebuild the import object the way mentl-host.mjs does. The worker only
// needs WASI + the shared memory + mentl_host stubs (a thread never execs;
// thread-spawn inside a thread nests via the same worker file).
const importObject = { wasi_snapshot_preview1: wasi.wasiImport };

// Memory import descriptor — same parse as the host.
// moduleBytes arrives via workerData (a Uint8Array after cloning).
function bytesToStr(b) { return String.fromCharCode.apply(null, b); }
function memoryImportDesc(bytes) {
  let p = 8;
  const u32 = () => { let r = 0, s = 0, by; do { by = bytes[p++]; r |= (by & 0x7f) << s; s += 7; } while (by & 0x80); return r >>> 0; };
  while (p < bytes.length) {
    const id = bytes[p++]; const len = u32(); const end = p + len;
    if (id === 2) {
      const n = u32();
      for (let i = 0; i < n; i++) {
        const ml = u32(); const mod = bytesToStr(bytes.slice(p, p + ml)); p += ml;
        const nl = u32(); const name = bytesToStr(bytes.slice(p, p + nl)); p += nl;
        const k = bytes[p++];
        if (k === 0x02) { const flags = u32(); u32(); if (flags & 1) u32(); return { mod, name }; }
        if (k === 0x00) u32(); else if (k === 0x01) { u32(); u32(); } else if (k === 0x03) u32();
      }
    }
    p = end;
  }
  return null;
}

const desc = memoryImportDesc(moduleBytes);
if (desc) importObject[desc.mod] = { [desc.name]: memory };
importObject.mentl_host = {
  wat_write: () => { throw new Error('wat_write from a spawned thread'); },
  exec: () => { throw new Error('exec from a spawned thread'); },
};
importObject.wasi = {
  'thread-spawn': () => { throw new Error('nested thread-spawn not implemented'); },
};

const module = new WebAssembly.Module(moduleBytes);
const instance = await WebAssembly.instantiate(module, importObject);
try {
  instance.exports.wasi_thread_start(tid, startArg);
  process.exit(0);
} catch (e) {
  if (e && typeof e.code === 'number') process.exit(e.code);
  process.exit(134);
}
