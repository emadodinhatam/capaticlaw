#!/usr/bin/env node
/**
 * CapatiClaw rebrand script — minimal safe rebrand for MVP.
 * Keeps internal OPENCLAW_ env vars / config keys intact for compat,
 * only changes user-facing branding + package identity.
 * Run: node scripts/rebrand-capaticlaw.mjs [--apply]
 * Without --apply: dry-run, prints what would change.
 */
import fs from "node:fs";
import path from "node:path";

const ROOT = path.resolve(import.meta.dirname, "..");
const APPLY = process.argv.includes("--apply");
const DRY = !APPLY;

let changed = 0;
let skipped = 0;

function log(msg) {
  console.log(msg);
}

function editFile(relPath, fn) {
  const abs = path.join(ROOT, relPath);
  if (!fs.existsSync(abs)) {
    skipped++;
    return;
  }
  const orig = fs.readFileSync(abs, "utf8");
  const next = fn(orig);
  if (next === orig) {
    skipped++;
    return;
  }
  changed++;
  log(`${DRY ? "[dry]" : "[write]"} ${relPath}`);
  if (!DRY) fs.writeFileSync(abs, next, "utf8");
}

// 1. package.json — core identity
editFile("package.json", (s) => {
  const j = JSON.parse(s);
  j.name = "capaticlaw";
  j.description = "CapatiClaw — AI assistant powered by Capati (fork of OpenClaw)";
  j.homepage = "https://github.com/emadodinhatam/capaticlaw#readme";
  j.bugs = { url: "https://github.com/emadodinhatam/capaticlaw/issues" };
  j.author = "Capati (https://capati.app)";
  j.repository = { type: "git", url: "git+https://github.com/emadodinhatam/capaticlaw.git" };
  // keep openclaw bin as alias for compat, add capaticlaw as primary
  j.bin = { capaticlaw: "capaticlaw.mjs", openclaw: "openclaw.mjs" };
  // keep openclaw key for compat, add capaticlaw key
  j.capaticlaw = j.openclaw;
  // files: add capaticlaw.mjs
  if (Array.isArray(j.files) && !j.files.includes("capaticlaw.mjs")) {
    const idx = j.files.indexOf("openclaw.mjs");
    if (idx !== -1) j.files.splice(idx + 1, 0, "capaticlaw.mjs");
    else j.files.push("capaticlaw.mjs");
  }
  // exports: add ./cli-entry for capaticlaw
  if (j.exports && !j.exports["./cli-entry-capaticlaw"]) {
    // keep existing
  }
  return JSON.stringify(j, null, 2) + "\n";
});

// 2. Create capaticlaw.mjs as copy of openclaw.mjs (with display name tweak)
{
  const src = path.join(ROOT, "openclaw.mjs");
  const dst = path.join(ROOT, "capaticlaw.mjs");
  if (!fs.existsSync(dst)) {
    const content = fs.readFileSync(src, "utf8");
    // Only change display strings, keep logic intact
    const next = content.replaceAll("OpenClaw", "CapatiClaw").replaceAll("openclaw", "capaticlaw");
    // But revert internal env var prefixes — keep OPENCLAW_ for compat
    const reverted = next
      .replaceAll("CAPATICLAW_", "OPENCLAW_")
      .replaceAll("capaticlaw.mjs", "capaticlaw.mjs"); // keep bin name
    // Actually keep OPENCLAW_ env vars; only binary name is capaticlaw
    // So undo the OPENCLAW_ revert for env vars is correct — we want to keep OPENCLAW_
    // The binary name stays capaticlaw.mjs
    log(`${DRY ? "[dry]" : "[write]"} capaticlaw.mjs (copy of openclaw.mjs with branding)`);
    if (!DRY) fs.writeFileSync(dst, reverted, "utf8");
    changed++;
  } else {
    skipped++;
  }
  // Ensure executable
  if (!DRY && fs.existsSync(dst)) {
    try {
      fs.chmodSync(dst, 0o755);
    } catch {}
  }
}

// 3. README branding
editFile("README.md", (s) =>
  s
    .replaceAll("OpenClaw", "CapatiClaw")
    .replaceAll("openclaw/openclaw", "emadodinhatam/capaticlaw")
    .replaceAll("openclaw.ai", "capati.app")
    .replaceAll("docs.openclaw.ai", "docs.capati.app")
    .replace("CapatiClaw Foundation", "Capati"),
);

// 4. Install scripts — URLs
for (const f of ["scripts/install.sh", "scripts/install.ps1", "scripts/install-cli.sh"]) {
  editFile(f, (s) =>
    s
      .replaceAll("openclaw.ai", "capati.app")
      .replaceAll("openclaw/openclaw", "emadodinhatam/capaticlaw")
      .replaceAll("OpenClaw", "CapatiClaw")
      .replaceAll("openclaw", "capaticlaw")
      // revert env var prefix
      .replaceAll("CAPATICLAW_", "OPENCLAW_")
      .replaceAll("CAPATICLAW_INSTALLER", "OPENCLAW_INSTALLER"),
  );
}

// 5. macOS Package.swift — bundle identity
editFile("apps/macos/Package.swift", (s) =>
  s
    .replaceAll("OpenClaw", "CapatiClaw")
    .replaceAll("openclaw", "capaticlaw")
    .replaceAll("com.capaticlaw", "com.capati.capaticlaw"),
);
editFile("apps/macos/Package.swift", (s) => {
  // Fix bundle ID specifically
  return s
    .replaceAll("com.capaticlaw", "com.capati.capaticlaw")
    .replace("com.capati.capaticlawcapaticlaw", "com.capati.capaticlaw");
});

// 6. Shared kit bundle IDs
for (const f of [
  "apps/shared/OpenClawKit/Package.swift",
  "apps/shared/OpenClawMLXTTSProtocol/Package.swift",
]) {
  editFile(f, (s) => s.replaceAll("OpenClaw", "CapatiClaw").replaceAll("openclaw", "capaticlaw"));
}

// 7. Linux Tauri config
editFile("apps/linux/src-tauri/tauri.conf.json", (s) => {
  try {
    const j = JSON.parse(s);
    if (j.productName) j.productName = "CapatiClaw";
    if (j.identifier) j.identifier = "com.capati.capaticlaw";
    if (j.build && j.build.productName) j.build.productName = "CapatiClaw";
    return JSON.stringify(j, null, 2) + "\n";
  } catch {
    return s.replaceAll("OpenClaw", "CapatiClaw").replaceAll("openclaw", "capaticlaw");
  }
});
editFile("apps/linux/src-tauri/Cargo.toml", (s) =>
  s.replaceAll("openclaw", "capaticlaw").replaceAll("OpenClaw", "CapatiClaw"),
);

// 8. Android / iOS identifiers
for (const f of [
  "apps/android/app/build.gradle.kts",
  "apps/android/app/src/main/AndroidManifest.xml",
  "apps/ios/OpenClawIOS/Info.plist",
]) {
  editFile(f, (s) =>
    s
      .replaceAll("com.openclaw", "com.capati.capaticlaw")
      .replaceAll("openclaw", "capaticlaw")
      .replaceAll("OpenClaw", "CapatiClaw"),
  );
}

log(
  `\nDone: ${changed} files changed, ${skipped} skipped/unchanged. ${DRY ? "(dry-run, use --apply to write)" : ""}`,
);
