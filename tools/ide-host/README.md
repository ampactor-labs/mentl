# tools/ide-host — the Mentl IDE static host (Railway)

Serves `ide/` (mentl edit, the web IDE) with the COOP/COEP headers its
shared-memory WASM requires. GitHub Pages cannot set these headers; this
server can.

## Deploy to Railway

From this directory:

```sh
railway login
railway init        # or link to an existing project
railway up
```

Railway assigns a URL like `mentl-ide.up.railway.app`. For a custom domain
(e.g. `ide.ampactor.dev`), add it in Railway's settings, then add a CNAME
in Porkbun: `ide` → your Railway URL.

## Local

```sh
node server.mjs        # :3000
PORT=7379 node server.mjs
```

The `ide/` folder here is a copy of the repo's `ide/` — refresh it when the
IDE changes, or symlink it in dev.
