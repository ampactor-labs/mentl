#!/usr/bin/env python3
"""tools/space-serve.py — serve a staged Mentl Space with the two isolation headers.

    python3 tools/space-serve.py [dir=.build/space] [port=7397]

The page needs the document to be cross-origin isolated (shared memory), so
the server adds the two headers to every response; the page's own service
worker (ide/isolate.js) does the same on hosts that cannot. This is the IDE
gate's local host for the STAGED artifact — the same files GitHub Pages
serves — never the repo root.
"""
import functools, http.server, os, sys

root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".build/space")
port = int(sys.argv[2]) if len(sys.argv) > 2 else 7397

class Isolated(http.server.SimpleHTTPRequestHandler):
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map,
                      ".wasm": "application/wasm", ".mn": "text/plain; charset=utf-8",
                      ".js": "application/javascript", ".mjs": "application/javascript",
                      ".woff2": "font/woff2", ".manifest": "text/plain; charset=utf-8"}
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()
    def log_message(self, *a):
        pass

if __name__ == "__main__":
    # the directory is named per request, never entered: a re-stage deletes
    # and recreates it under a running server, and the next request is served
    # from the new tree (a server standing in the deleted directory answered
    # every request with an empty response)
    handler = functools.partial(Isolated, directory=root)
    http.server.ThreadingHTTPServer(("127.0.0.1", port), handler).serve_forever()
