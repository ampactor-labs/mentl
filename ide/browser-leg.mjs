// ide/browser-leg.mjs — the browser leg of the IDE gate: headless Chrome driven
// over its own debugging pipe.
//
//   node ide/browser-leg.mjs <chrome> <base-url> [shot-dir]
//
// It opens the staged site at ?smoke, prints the page's console wire — the
// SMOKE lines the page logs (ide/index.html smoke()) and any uncaught page
// error as PAGE-ERROR — as each arrives, captures a screenshot once the
// canvas leg, the last, has run (the page as the developer sees it: the
// canvas fixture painted from the wheel's spans, its strip, frames and marks,
// the caret projected),
// then opens the parchment ground and captures it when the page says
// SPACE-READY. Chrome's own --screenshot cannot do this: it captures at the
// load event, before the wheel has booted, and under --virtual-time-budget
// it never returns on this page (the session's worker blocks inside the
// wheel's read). The exit code is the last leg's: 0 when SMOKE-CANVAS
// printed, 1 otherwise, with whatever lines arrived on stdout.
import { spawn } from "node:child_process";
import { mkdtempSync, writeFileSync, rmSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const [chrome, base, shotDir = ".build"] = process.argv.slice(2);
if (!chrome || !base) { console.error("usage: node ide/browser-leg.mjs <chrome> <base-url> [shot-dir]"); process.exit(2); }
mkdirSync(shotDir, { recursive: true });
const prof = mkdtempSync(join(tmpdir(), "space-gate-"));
const child = spawn(chrome, [
  "--headless=new", "--disable-gpu", "--no-sandbox", `--user-data-dir=${prof}`,
  "--remote-debugging-pipe", "--window-size=1600,1000", "--hide-scrollbars", "about:blank",
], { stdio: ["ignore", "ignore", "ignore", "pipe", "pipe"] });
const toChrome = child.stdio[3], fromChrome = child.stdio[4];

let nextId = 1;
const pending = new Map(), listeners = new Set();
function send(method, params = {}, sessionId) {
  const id = nextId++;
  const msg = { id, method, params };
  if (sessionId) msg.sessionId = sessionId;
  toChrome.write(JSON.stringify(msg) + "\0");
  return new Promise((res, rej) => pending.set(id, { res, rej }));
}
let buf = "";
fromChrome.on("data", (d) => {
  buf += d.toString();
  let i;
  while ((i = buf.indexOf("\0")) >= 0) {
    const m = JSON.parse(buf.slice(0, i)); buf = buf.slice(i + 1);
    if (m.id !== undefined && pending.has(m.id)) {
      const p = pending.get(m.id); pending.delete(m.id);
      m.error ? p.rej(new Error(`${m.error.message} (${JSON.stringify(m.error)})`)) : p.res(m.result);
    } else if (m.method) for (const l of listeners) l(m);
  }
});

// Open a page and resolve with the first console line `want` accepts, or
// null after `ms`; every SMOKE / SPACE-READY line and every page error is
// printed as it arrives, so a timeout still leaves the record on stdout.
async function open(url, want, ms) {
  const { targetId } = await send("Target.createTarget", { url: "about:blank" });
  const { sessionId } = await send("Target.attachToTarget", { targetId, flatten: true });
  await send("Runtime.enable", {}, sessionId);
  await send("Page.enable", {}, sessionId);
  let done;
  const found = new Promise((r) => { done = r; });
  const timer = setTimeout(() => done(null), ms);
  const listen = (m) => {
    if (m.sessionId !== sessionId) return;
    if (m.method === "Runtime.consoleAPICalled") {
      const text = (m.params.args || []).map((a) => (a.value !== undefined ? String(a.value) : a.description || "")).join(" ");
      if (/^(SMOKE|SPACE-READY)/.test(text)) console.log(text);
      if (want(text)) done(text);
    } else if (m.method === "Runtime.exceptionThrown") {
      const e = m.params.exceptionDetails;
      console.log(`PAGE-ERROR ${(e.exception && e.exception.description) || e.text} at ${e.url || ""}:${e.lineNumber}`);
    }
  };
  listeners.add(listen);
  await send("Page.navigate", { url }, sessionId);
  const line = await found;
  clearTimeout(timer); listeners.delete(listen);
  return { sessionId, line };
}
async function shot(sessionId, path) {
  const { data } = await send("Page.captureScreenshot", { format: "png" }, sessionId);
  writeFileSync(path, Buffer.from(data, "base64"));
}

let ok = false;
try {
  const sep = base.includes("?") ? "&" : "?";
  const a = await open(`${base}${sep}smoke&theme=obsidian`, (t) => /^SMOKE-CANVAS|^SMOKE-BOOT-FAIL/.test(t), 240000);
  if (a.line === null) console.log("SMOKE-TIMEOUT the page printed no SMOKE-CANVAS line in 240 s");
  ok = !!(a.line && a.line.startsWith("SMOKE-CANVAS"));
  await shot(a.sessionId, join(shotDir, "space.png"));
  const b = await open(`${base}${sep}theme=parchment`, (t) => /^SPACE-READY/.test(t), 60000);
  if (b.line !== null) await shot(b.sessionId, join(shotDir, "space-parchment.png"));
} catch (e) {
  console.log(`BROWSER-LEG-ERROR ${e.message}`);
} finally {
  try { await send("Browser.close"); } catch (e) { child.kill("SIGKILL"); }
  await new Promise((r) => { child.on("exit", r); setTimeout(() => { child.kill("SIGKILL"); r(); }, 5000); });
  rmSync(prof, { recursive: true, force: true });
}
process.exit(ok ? 0 : 1);
