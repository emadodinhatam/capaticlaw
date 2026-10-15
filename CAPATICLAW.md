# CapatiClaw — Fork Plan & Build Guide

> **Fork of [openclaw/openclaw](https://github.com/openclaw/openclaw) (MIT, 391k stars)**
> Isolated from `/srv/capati/prod` — no changes to prod panel/API.

## What was done

### 1. Rebrand (minimal, safe)

- `package.json`: `bin: { capaticlaw: capaticlaw.mjs, openclaw: openclaw.mjs }` (both work), `capaticlaw` key added
- `capaticlaw.mjs`: copy of `openclaw.mjs` with display strings → CapatiClaw (keeps `OPENCLAW_` env vars for compat)
- `src/cli/cli-name.ts`: `CLI_NAME = "capaticlaw"` (was `openclaw`) — controls `Usage: capaticlaw ...`
- `src/cli/tagline.ts`: `All your chats, one CapatiClaw.`
- `src/cli/banner.ts`: `CapatiClaw` title
- `src/cli/program/help.ts`: version line + examples use `capaticlaw`
- `src/cli/run-main.ts`: `program.name(CLI_NAME)`
- `apps/macos/Package.swift`, `apps/shared/*`, `apps/linux/src-tauri/*`, `apps/android/*`: bundle IDs → `com.capati.capaticlaw`
- `scripts/install.sh`, `install.ps1`, `install-cli.sh`: URLs → `capati.app` / `emadodinhatam/capaticlaw`
- `README.md`: branding → CapatiClaw

**Kept as `openclaw` internally:** `package.json:name` stays `openclaw` for `workspace:*` compat (192 workspaces). Publish name handled via tag.

### 2. Skill: Capati

- `skills/capati/SKILL.md` — wraps `panel.capati.app` API:
  - Video dub/translate: `POST /api/upload/*`, `GET /api/status/<id>`, `GET /api/download/...`
  - Chat AI: `POST /api/chat-ai/conversations/<id>/send`, image/video/pptx/doc/excel/music jobs
  - Config via `CAPATI_TOKEN` / `capati.token`

### 3. CI/CD

- `.github/workflows/capaticlaw-release.yml` — matrix:
  - `build-gateway` (ubuntu-24.04, Node 24, pnpm 12) → `dist/` + npm tarball
  - `build-macos-intel` (macos-13, x86_64) → DMG/zip
  - `build-macos-arm` (macos-14, arm64) → DMG/zip
  - `build-windows` (windows-latest, x64) → EXE (best-effort, needs `openclaw-windows-node` fork for full Hub)
  - `build-linux` (ubuntu-24.04) → AppImage/deb/tar.gz fallback
  - `publish` (on tag `v*`) → draft GitHub Release

### 4. Helpers

- `scripts/rebrand-capaticlaw.mjs` — re-runnable rebrand script (`--apply` to write)

## Build locally

```bash
cd /home/capati/capaticlaw
# Requires Node 24.21.0 + pnpm 12
pnpm install --frozen-lockfile
pnpm build:runtime        # ~4 min, produces dist/
node capaticlaw.mjs --version  # CapatiClaw 2026.10.3
node capaticlaw.mjs --help     # Usage: capaticlaw ...
```

## Test gateway (isolated)

```bash
node capaticlaw.mjs onboard --install-daemon   # creates ~/.capaticlaw/
node capaticlaw.mjs gateway status
node capaticlaw.mjs dashboard
```

Uses `~/.capaticlaw/` (not `~/.openclaw/` if `OPENCLAW_STATE_DIR` is set via capaticlaw.mjs state paths — currently still `~/.openclaw` for compat; override with `OPENCLAW_STATE_DIR=~/.capaticlaw`).

## Publish

```bash
# Tag triggers CI
git tag v2026.10.3-capati.1 && git push origin v2026.10.3-capati.1
# Or manual: gh workflow run capaticlaw-release.yml
```

For npm: `pnpm pack` → `npm publish --tag capati` (after setting `package.json:name` to `capaticlaw` for publish).

## Remaining for full desktop

- **macOS signing:** Apple Developer cert + `notarytool` (add to `build-macos-*` jobs)
- **Windows Hub:** fork `openclaw/openclaw-windows-node` → `capaticlaw-windows-node`, rebrand, build `Setup-x64.exe`
- **Linux Tauri:** needs `cargo` + `tauri-cli` on runner (already in `build-linux` as best-effort)
- **State dir:** optionally change `~/.openclaw` → `~/.capaticlaw` in `src/config/paths.ts` (kept compat for now)

## Isolation guarantee

- No file under `/srv/capati/prod` was touched
- All changes under `/home/capati/capaticlaw` (separate git repo, separate `node_modules`, separate `dist`)
- Prod panel still on `18100/18101` via systemd, unaffected
