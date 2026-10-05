#!/usr/bin/env node
// mentl-host — the zero-Rust host for Mentl modules.
//
// Runs boot/mentl.wasm (or any Mentl-emitted module) on Node's own engine:
// WASI preview1, the shared env.memory import, mentl_host (wat_write/exec),
// and wasi/thread-spawn via worker_threads.
//
// CLI-compatible with tools/runner's mentl-runner for the flag subset the
// mentl shim uses:
//   mentl-host run [-W v] [-S v] [-D v] [--dir h[::g]] [--env K=V] \
//                  <module.wasm> [guest argv...]
// -W/-D are accepted and ignored (threads + tail-call are always on).
// stdin/stdout/stderr pass through; exit code = guest exit code; a trap is
// 134, the status the micro battery banks.
//
// The host is a SEAM, not an engine: WASI, shared memory, streamed-WAT
// execution, sockets. Any host honoring this contract runs the wheel.

import { WASI } from 'node:wasi';
import { Worker } from 'node:worker_threads';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// ── CLI ────────────────────────────────────────────────────────────────

function parseCli(argv) {
  const args = argv.slice(2);
  if (args[0] !== 'run') {
    console.error(`usage: mentl-host run [flags] <module.wasm> [args...]`);
    process.exit(2);
  }
  const spec = { preopens: [], envs: [], tcplisten: null };
  let i = 1, modulePath = null;
  while (i < args.length) {
    const a = args[i];
    if (modulePath !== null) break;
    if (a === '-W' || a === '-D') { i += 2; continue; }
    if (a === '-S') {
      const v = args[i + 1]; i += 2;
      if (v.startsWith('tcplisten=')) spec.tcplisten = v.slice('tcplisten='.length);
      continue;
    }
    if (a.startsWith('-S')) {
      const v = a.slice(2);
      if (v.startsWith('tcplisten=')) spec.tcplisten = v.slice('tcplisten='.length);
      i++; continue;
    }
    if (a.startsWith('-W') || a.startsWith('-D')) { i++; continue; }
    if (a === '--dir') {
      const v = args[i + 1]; i += 2;
      const j = v.indexOf('::');
      spec.preopens.push(j >= 0 ? [v.slice(0, j), v.slice(j + 2)] : [v, v]);
      continue;
    }
    if (a === '--env') {
      const v = args[i + 1]; i += 2;
      const j = v.indexOf('=');
      spec.envs.push([v.slice(0, j), v.slice(j + 1)]);
      continue;
    }
    if (a.startsWith('-')) { console.error(`mentl-host: unknown flag: ${a}`); process.exit(2); }
    modulePath = a; i++; break;
  }
  if (!modulePath) { console.error('mentl-host: no module path given'); process.exit(2); }
  spec.argv = [modulePath, ...args.slice(i)];
  spec.modulePath = modulePath;
  return spec;
}

// ── module loading ─────────────────────────────────────────────────────

let _wabt = null;
async function wabt() {
  if (!_wabt) {
    const factory = (await import('wabt')).default;
    _wabt = await factory();
  }
  return _wabt;
}

function isWasm(bytes) {
  return bytes.length >= 4 && bytes[0] === 0x00 && bytes[1] === 0x61 && bytes[2] === 0x73 && bytes[3] === 0x6d;
}

async function loadModule(modulePath) {
  const bytes = fs.readFileSync(modulePath);
  if (isWasm(bytes)) return { module: new WebAssembly.Module(bytes), bytes };
  const w = await wabt();
  const m = w.parseWat(path.basename(modulePath), bytes.toString('utf8'), { tail_call: true, threads: true });
  const bin = Buffer.from(m.toBinary({}).buffer);
  return { module: new WebAssembly.Module(bin), bytes: bin };
}

// Declared shared-memory import, parsed from the import section
// (WebAssembly.Module.imports() hides the memory descriptor).
function memoryImportDesc(bytes) {
  let p = 8;
  const u32 = () => { let r = 0, s = 0, by; do { by = bytes[p++]; r |= (by & 0x7f) << s; s += 7; } while (by & 0x80); return r >>> 0; };
  while (p < bytes.length) {
    const id = bytes[p++]; const len = u32(); const end = p + len;
    if (id === 2) {
      const n = u32();
      for (let i = 0; i < n; i++) {
        const ml = u32(); const mod = bytes.slice(p, p + ml).toString(); p += ml;
        const nl = u32(); const name = bytes.slice(p, p + nl).toString(); p += nl;
        const k = bytes[p++];
        if (k === 0x02) {
          const flags = u32(); const min = u32(); const max = (flags & 1) ? u32() : null;
          return { mod, name, shared: (flags & 2) !== 0, min, max };
        }
        if (k === 0x00) u32(); else if (k === 0x01) { u32(); u32(); } else if (k === 0x03) u32();
      }
    }
    p = end;
  }
  return null;
}

// ── memory views ───────────────────────────────────────────────────────

function dv(mem) { return new DataView(mem.buffer); }
function readI32(mem, ptr) { return dv(mem).getInt32(ptr, true); }
function writeI32(mem, ptr, v) { dv(mem).setInt32(ptr, true, v); }
function readBytes(mem, ptr, len) { return Buffer.from(mem.buffer.slice(ptr, ptr + len)); }
function writeBytes(mem, ptr, buf) { new Uint8Array(mem.buffer, ptr, buf.length).set(buf); }

// ── one instance ───────────────────────────────────────────────────────
// Returns the guest's exit code (a VALUE — only the root process exits).
//
// Synchronous throughout: the wasm import signature is sync, so exec's
// child must run to completion before returning. wabt is pre-initialized
// in main(); Module/Instance construction and the child's WASI are sync.

function runModuleSync(loaded, spec, opts = {}) {
  const { module, bytes } = loaded;
  const wasi = new WASI({
    version: 'preview1',
    args: spec.argv,
    env: Object.fromEntries(spec.envs),
    preopens: Object.fromEntries(spec.preopens.map(([h, g]) => [g, h])),
    returnOnExit: true,
  });

  // The -S tcplisten= socket seam (mentl session/space) is the named
  // remainder: it needs a sync<->async bridge (worker + Atomics) that is
  // not yet built. The Rust runner still owns this seam.
  if (spec.tcplisten && !opts.isChild) {
    console.error('mentl-host: the -S tcplisten= socket seam is not implemented yet (mentl session/space need it); the Rust runner owns this seam');
    return 2;
  }

  let memory = opts.sharedMemory || null;
  let memDesc = bytes ? memoryImportDesc(bytes) : null;
  if (!memory && memDesc) {
    memory = new WebAssembly.Memory({
      shared: memDesc.shared,
      initial: memDesc.min,
      ...(memDesc.max != null ? { maximum: memDesc.max } : {}),
    });
  }

  // The exec seam's stream: wat_write appends; exec takes it whole.
  let wat = [];

  const importObject = { wasi_snapshot_preview1: wasi.wasiImport };
  if (memory && memDesc) importObject[memDesc.mod] = { [memDesc.name]: memory };

  const needsSpawn = WebAssembly.Module.imports(module).some((im) => im.name === 'thread-spawn');
  if (needsSpawn) {
    importObject.wasi = {
      'thread-spawn': (startArg) => {
        const tid = opts.nextTid();
        const worker = new Worker(path.join(__dirname, 'thread-worker.mjs'), {
          workerData: {
            moduleBytes: bytes, memory, tid, startArg,
            spec: { argv: spec.argv, envs: spec.envs, preopens: spec.preopens },
          },
        });
        worker.once('exit', (code) => { if (code !== 0) process.exit(code); });
        worker.unref();
        return tid;
      },
    };
  }

  importObject.mentl_host = {
    wat_write: (ptr, len) => { wat.push(readBytes(memory, ptr, len)); },
    // Synchronous by contract: the import signature is (i32,i32)->i32, so
    // a Promise return would coerce to garbage. wabt is pre-initialized,
    // Module/Instance construction is sync, and the child's WASI is sync —
    // the whole child runs to completion before this returns its exit code.
    exec: (argvPtr, argvLen) => {
      const argvBytes = readBytes(memory, argvPtr, argvLen);
      const watText = Buffer.concat(wat).toString('utf8'); wat = [];
      const argv = argvBytes.toString('utf8').split('\0').filter((a) => a.length > 0);
      let childBin;
      try {
        childBin = Buffer.from(_wabt.parseWat('exec.wat', watText, { tail_call: true, threads: true }).toBinary({}).buffer);
      } catch (e) {
        console.error(`mentl_host.exec: the streamed module does not assemble: ${e.message.split('\n')[0]}`);
        return 1;
      }
      let childMod;
      try {
        childMod = new WebAssembly.Module(childBin);
      } catch (e) {
        console.error(`mentl_host.exec: bad module: ${e.message}`);
        return 1;
      }
      const childSpec = {
        argv: argv.length > 0 ? argv : ['mentl-exec'],
        envs: spec.envs, preopens: spec.preopens,
      };
      try {
        return runModuleSync({ module: childMod, bytes: childBin }, childSpec,
          { isChild: true, nextTid: opts.nextTid });
      } catch (e) {
        return 134;
      }
    },
  };

  const instance = new WebAssembly.Instance(module, importObject);
  const entry = opts.entry || '_start';
  try {
    if (opts.isThread) {
      // Threads enter at wasi_thread_start, not via WASI start.
      instance.exports[entry](opts.tid, opts.startArg);
    } else {
      // wasi.start binds the instance BEFORE calling _start — the WASI
      // functions find memory through that binding. Calling the export
      // directly leaves them blind (fd_write silently writes nowhere).
      // With returnOnExit, start RETURNS the proc_exit code (no throw).
      const code = wasi.start(instance);
      return typeof code === 'number' ? code : 0;
    }
    return 0;
  } catch (e) {
    if (e && typeof e.code === 'number') return e.code; // WASIExitError
    throw e;
  }
}

async function main() {
  const spec = parseCli(process.argv);
  await wabt(); // pre-initialize: exec's child assembly is synchronous
  const loaded = await loadModule(spec.modulePath);
  let nextTid = 2;
  try {
    const code = runModuleSync(loaded, spec, { nextTid: () => nextTid++ });
    process.exit(code);
  } catch (e) {
    if (e instanceof WebAssembly.RuntimeError) process.exit(134);
    console.error(`mentl-host: ${e.stack || e.message}`);
    process.exit(1);
  }
}

main();
