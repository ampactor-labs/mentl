// isolate.js — the page's own cross-origin isolation and offline cache.
//
// Shared memory and SharedArrayBuffer need the document to be cross-origin
// isolated, which takes two response headers no static host sets by itself
// (GitHub Pages cannot). This worker adds them to every same-origin
// response, so the page isolates itself wherever it is served — Pages, a
// local static server, a file copied to a stick — and keeps a copy of
// everything it fetched, so a page that opened once opens again offline.
// The page registers it and reloads once when it was not yet isolated.
const CACHE = "mentl-space-v1";
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (e) => e.waitUntil(self.clients.claim()));
self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  if (req.cache === "only-if-cached" && req.mode !== "same-origin") return;
  e.respondWith((async () => {
    const cache = await caches.open(CACHE);
    let res;
    try {
      res = await fetch(req);
      if (res.ok && new URL(req.url).origin === self.location.origin) cache.put(req, res.clone());
    } catch (err) {
      res = await cache.match(req);
      if (!res) throw err;
    }
    if (res.status === 0 || res.type === "opaque") return res;   // cross-origin, untouched
    const headers = new Headers(res.headers);
    headers.set("Cross-Origin-Opener-Policy", "same-origin");
    headers.set("Cross-Origin-Embedder-Policy", "require-corp");
    return new Response(res.body, { status: res.status, statusText: res.statusText, headers });
  })());
});
