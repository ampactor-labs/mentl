/* session-client.js — the host side of the resident session (E2), one file
   for the page (ide/index.html) and the node twin (ide/test-shim.mjs), so
   the two cannot drift.

   The session is ONE wheel instance running `mentl session` inside a worker
   (ide/wheel-worker.js, role "session"): the graph is derived once, and every
   answer after that is a read of it — an edit re-judges only the cone it
   moved (src/mcp.mn session_current). A request is a verb's argv plus the
   files that changed since the last request; the answer is what the verb
   printed. A verb the session does not serve answers the MISS sentinel and is
   re-run COLD (a fresh instance, the `run` role), and so is a refusal — the
   session says a verb resident only when it can say it whole (src/main.mn
   session_whole), and a refusal's whole answer is its stderr and its exit
   code, which the cold run carries.

   The worker blocks inside the wheel's own read between requests, so the
   channel is a SharedArrayBuffer (layout in ide/wheel-worker.js) and the
   host waits on it with Atomics.waitAsync: the page's main thread may never
   block, and a blocked worker can neither receive nor flush a postMessage.

   Every call is timed (`ms`) and says which route answered it (`resident`),
   so "the session answers in under 50 ms" is a measurement the twin and the
   page report rather than a sentence. */
(function (root, make) {
  if (typeof module === "object" && module.exports) module.exports = make();
  else root.MentlSession = make();
})(typeof self !== "undefined" ? self : globalThis, function () {
  "use strict";
  const CH_WORDS = 8, CH_DATA = 4 * CH_WORDS;
  const REQ_BYTES = 4 << 20, REP_BYTES = 16 << 20;
  const MISS = "MENTL-SESSION-MISS";
  const td = new TextDecoder(), te = new TextEncoder();
  const now = () => (typeof performance !== "undefined" ? performance.now() : Date.now());
  const asText = (v) => (typeof v === "string" ? v : td.decode(v));
  const asBytes = (v) => (typeof v === "string" ? te.encode(v) : v);

  // Wait until word `i` moves off `seen`, up to `ms`. waitAsync where the host
  // has it (node, Chrome); a 1 ms poll where it does not.
  async function moved(ctl, i, seen, ms) {
    const deadline = now() + ms;
    while (Atomics.load(ctl, i) === seen) {
      const left = deadline - now();
      if (left <= 0) return false;
      if (Atomics.waitAsync) {
        const w = Atomics.waitAsync(ctl, i, seen, left);
        if (w.async) await w.value;
      } else {
        await new Promise((r) => setTimeout(r, 1));
      }
    }
    return true;
  }

  class Session {
    // spawn() -> {post(msg), terminate(), onError(fn)}: a fresh wheel-worker.
    // runCold({argv, vfs}) -> the `run` role's reply, for MISS and refusals.
    constructor({ spawn, module, vfs, runCold, memPages, openMs, callMs }) {
      this.spawn = spawn; this.module = module; this.runCold = runCold;
      this.memPages = memPages || 16384;
      this.openMs = openMs || 120000; this.callMs = callMs || 60000;
      this.vfs = Object.assign({}, vfs || {});   // the tree as the host knows it
      this.unsent = {};                          // files the session has not seen
      this.worker = null; this.opened = null; this.died = null; this.unavailable = null;
    }

    // Open the session over the tree as it stands: one derivation, timed.
    async open() {
      this.channel = new SharedArrayBuffer(CH_DATA + REQ_BYTES + REP_BYTES);
      this.ctl = new Int32Array(this.channel, 0, CH_WORDS);
      this.ctl[5] = REQ_BYTES; this.ctl[6] = REP_BYTES;
      this.req = new Uint8Array(this.channel, CH_DATA, REQ_BYTES);
      this.rep = new Uint8Array(this.channel, CH_DATA + REQ_BYTES, REP_BYTES);
      this.replies = 0;
      this.died = null;
      const t0 = now();
      this.worker = this.spawn();
      this.worker.onError((e) => { this.died = String((e && e.message) || e); });
      // the session starts over the host's whole tree, so nothing is unsent
      this.worker.post({ role: "session", module: this.module, memPages: this.memPages,
                         vfs: Object.assign({}, this.vfs), channel: this.channel });
      this.unsent = {};
      const r = await this.reply(this.openMs);
      if (!r || r.state !== 1) {
        this.close();
        return { ok: false, ms: now() - t0, why: this.died || (r ? (r.trapped || r.err || `the session ended (exit ${r.exit})`) : "no answer before the open timed out") };
      }
      this.opened = { ms: now() - t0, err: r.err, memoryBytes: r.memoryBytes };
      return { ok: true, ms: this.opened.ms, err: r.err, memoryBytes: r.memoryBytes };
    }

    async reply(ms) {
      if (!(await moved(this.ctl, 2, this.replies, ms))) return null;
      this.replies = Atomics.load(this.ctl, 2);
      return JSON.parse(td.decode(this.rep.slice(0, Atomics.load(this.ctl, 3))));
    }

    // Ask the session: argv as the CLI spells it (["mentl", ...]), plus the
    // files that changed. Resolves to the `run` role's reply shape with `ms`,
    // `resident` and, when the session could not answer, `why`.
    async call(argv, delta) {
      for (const [p, v] of Object.entries(delta || {})) { this.vfs[p] = asBytes(v); this.unsent[p] = asText(v); }
      const t0 = now();
      if (this.unavailable) return this.cold(argv, t0, this.unavailable);
      if (!this.worker) {
        const o = await this.open();
        // a module that cannot serve a session (one older than the stdin
        // transport) refuses the same way every time: say so once, then
        // answer cold without paying the attempt on every call
        if (!o.ok) { this.unavailable = "the session did not open: " + o.why; return this.cold(argv, t0, this.unavailable); }
      }
      const body = te.encode(JSON.stringify({ line: argv.slice(1).join("\t"), delta: this.unsent }));
      if (body.length > this.req.length) return this.cold(argv, t0, `the request (${body.length} bytes) exceeds the channel`);
      this.unsent = {};
      this.req.set(body);
      Atomics.store(this.ctl, 1, body.length);
      Atomics.add(this.ctl, 0, 1);
      Atomics.notify(this.ctl, 0);
      const r = await this.reply(this.callMs);
      if (!r || r.state !== 1) {
        // a session that hangs or ends mid-answer is closed loudly; this call
        // answers cold and the next one opens a fresh session
        const why = !r ? "the session did not answer in time" : (r.trapped || `the session ended (exit ${r.exit})`);
        this.close();
        return this.cold(argv, t0, why);
      }
      // what the session wrote is already in its tree; the host's follows
      for (const [p, text] of Object.entries(r.written || {})) this.vfs[p] = te.encode(text);
      if (r.out.startsWith(MISS)) return this.cold(argv, t0, null);
      const written = Object.fromEntries(Object.entries(r.written || {}).map(([p, text]) => [p, te.encode(text)]));
      return { exit: 0, out: r.out, err: r.err, trapped: null, tasks: 0, written,
               ms: now() - t0, resident: true, memoryBytes: r.memoryBytes };
    }

    async cold(argv, t0, why) {
      const r = await this.runCold({ argv, vfs: Object.assign({}, this.vfs) });
      // a cold write is news to the session: it rides the next request
      for (const [p, v] of Object.entries(r.written || {})) { this.vfs[p] = v; this.unsent[p] = asText(v); }
      return Object.assign({}, r, { ms: now() - t0, resident: false, why });
    }

    close() {
      if (this.worker) this.worker.terminate();
      this.worker = null;
    }
  }
  return { Session, MISS };
});
