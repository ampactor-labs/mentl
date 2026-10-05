// server.mjs — static host for the Mentl IDE with COOP/COEP headers.
//
// The IDE (mentl-ide.wasm) uses SharedArrayBuffer (shared-memory WASM +
// thread-spawn), which requires these headers:
//   Cross-Origin-Opener-Policy: same-origin
//   Cross-Origin-Embedder-Policy: require-corp
// GitHub Pages cannot set them; this server (Railway, or any Node host) can.

import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, 'ide');

const mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.wasm': 'application/wasm',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.mn': 'text/plain; charset=utf-8',
};

const server = http.createServer((req, res) => {
  const urlPath = req.url.split('?')[0];
  const filePath = path.join(root, urlPath === '/' ? 'index.html' : urlPath.slice(1));
  if (!filePath.startsWith(root)) {
    res.writeHead(403);
    res.end('forbidden');
    return;
  }
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('not found');
      return;
    }
    res.writeHead(200, {
      'Content-Type': mime[path.extname(filePath)] || 'application/octet-stream',
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
      'Cache-Control': 'no-store',
    });
    res.end(data);
  });
});

const port = parseInt(process.env.PORT || '3000', 10);
server.listen(port, () => {
  console.log(`mentl-ide-host serving ${root} on :${port} with COOP/COEP`);
});
