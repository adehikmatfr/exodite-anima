#!/usr/bin/env node
'use strict';
// Preflight and publish-safety check for .assist.
// Usage: node preflight.js [path-to-.assist]
//   (default path: current directory, or its .assist child)
//
// Reports, in order:
//   1. required files and role files that are missing;
//   2. context files that still contain template placeholders;
//   3. pending decisions and spec statuses (information);
//   4. the ID registry check (runs check-registry.js);
//   5. publish-safety scan of .assist, docs, and root files: secrets (error),
//      emails, absolute local paths, CRLF line endings (warning);
//   6. whether the root .gitignore blocks common secret file names;
//   7. freshness: warns when status.md, or a role's context.md, is older than
//      the newest work it should describe (by file time; a fresh git checkout
//      gives every file the same time, so it stays quiet then).
// Exit code 1 only when there are errors. Warnings never fail the run.

const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

function findRoot() {
  const start = path.resolve(process.argv[2] || '.');
  for (const c of [start, path.join(start, '.assist')]) {
    if (fs.existsSync(path.join(c, '_shared', 'index.md'))) return c;
  }
  console.error('error: no _shared/index.md under ' + start);
  process.exit(2);
}

const root = findRoot();
const repo = path.dirname(root);
const errors = [];
const warnings = [];
const info = [];

const SKIP_DIRS = new Set(['node_modules', '.git', '__pycache__', 'build', '.dart_tool', '.gradle']);
const TEXT_EXT = new Set(['.md', '.js', '.json', '.pen', '.py', '.yaml', '.yml', '.txt', '.dart', '.gitignore', '.gitattributes']);

function walk(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (e.isDirectory()) {
      if (!SKIP_DIRS.has(e.name)) walk(path.join(dir, e.name), out);
    } else if (TEXT_EXT.has(path.extname(e.name)) || e.name.startsWith('.git')) {
      out.push(path.join(dir, e.name));
    }
  }
  return out;
}
const rel = (p) => path.relative(repo, p).replace(/\\/g, '/');

// 1. required files
const required = ['README.md', 'orchestration.md', 'status.md', 'publishing.md',
  '_shared/project.md', '_shared/domain-context.md', '_shared/glossary.md', '_shared/index.md',
  '_shared/compliance/compliance-matrix.md', 'tools/check-registry.js'];
for (const f of required) {
  if (!fs.existsSync(path.join(root, f))) errors.push(`missing required file: .assist/${f}`);
}
const roles = fs.readdirSync(root, { withFileTypes: true })
  .filter((e) => e.isDirectory() && fs.existsSync(path.join(root, e.name, 'prompts', 'role.md')))
  .map((e) => e.name);
for (const r of roles) {
  if (!fs.existsSync(path.join(root, r, 'context.md'))) errors.push(`role ${r}: missing context.md`);
}

// 2. unfilled placeholders in context files and core shared files
const PLACEHOLDER = /`?<[A-Za-z][^<>|\n]{2,70}>`?/g;
const contextFiles = roles.map((r) => path.join(root, r, 'context.md'))
  .concat(['project.md', 'domain-context.md', 'glossary.md'].map((f) => path.join(root, '_shared', f)));
for (const f of contextFiles) {
  if (!fs.existsSync(f)) continue;
  const text = fs.readFileSync(f, 'utf8')
    .replace(/```[\s\S]*?```/g, '')
    // inline code that is a path or a command uses <...> as syntax, not as a template placeholder
    .replace(/`[^`\n]*`/g, (m) => (/[\/\\]/.test(m) || /^`(python|node|npm|flutter|git|openpencil) /.test(m) ? '' : m));
  const n = (text.match(PLACEHOLDER) || []).length;
  if (n > 0) warnings.push(`${rel(f)}: ${n} template placeholder(s) left to fill`);
}

// 3. pending decisions and spec statuses
const decDir = path.join(root, 'product-manager', 'decisions');
if (fs.existsSync(decDir)) {
  const pending = [];
  for (const f of fs.readdirSync(decDir)) {
    if (!f.endsWith('.md') || f === 'README.md') continue;
    const t = fs.readFileSync(path.join(decDir, f), 'utf8');
    if (/\|\s*Status\s*\|\s*pending\s*\|/i.test(t)) pending.push(f.replace(/\.md$/, ''));
  }
  info.push(`pending decisions (${pending.length}): ${pending.join(', ') || 'none'}`);
}
const featDir = path.join(root, 'product-manager', 'features');
if (fs.existsSync(featDir)) {
  const counts = {};
  for (const f of fs.readdirSync(featDir)) {
    if (!/^FEAT-\d{3}/.test(f)) continue;
    const t = fs.readFileSync(path.join(featDir, f), 'utf8');
    const m = /\|\s*Status\s*\|\s*([a-z-]+)/i.exec(t);
    const s = m ? m[1].toLowerCase() : 'unknown';
    counts[s] = (counts[s] || 0) + 1;
  }
  info.push('feature specs by status: ' + (Object.entries(counts).map(([k, v]) => `${k} ${v}`).join(', ') || 'none'));
}

// 4. registry check
const reg = spawnSync(process.execPath, [path.join(root, 'tools', 'check-registry.js'), root], { encoding: 'utf8' });
if (reg.status === 0) info.push('registry: ' + (reg.stdout.trim().split('\n').pop() || 'ok'));
else errors.push('registry check failed:\n' + (reg.stderr || reg.stdout).trim().split('\n').map((l) => '    ' + l).join('\n'));

// 5. publish-safety scan
const scanDirs = [root, path.join(repo, 'docs'), path.join(repo, 'app', 'lib')];
const scanFiles = walk(root).concat(walk(path.join(repo, 'docs')), walk(path.join(repo, 'app', 'lib')));
for (const f of ['README.md', 'CLAUDE.md', 'SECURITY.md']) if (fs.existsSync(path.join(repo, f))) scanFiles.push(path.join(repo, f));
const pubspec = path.join(repo, 'app', 'pubspec.yaml');
if (fs.existsSync(pubspec)) scanFiles.push(pubspec);

const SECRETS = [
  [/-----BEGIN [A-Z ]*PRIVATE KEY-----/, 'private key'],
  [/ghp_[A-Za-z0-9]{30,}/, 'GitHub token'],
  [/AKIA[0-9A-Z]{16}/, 'AWS access key id'],
  [/xox[baprs]-[A-Za-z0-9-]{10,}/, 'Slack token'],
  [/AIza[0-9A-Za-z_-]{35}/, 'Google API key'],
];
const EMAIL = /[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}/g;
const LOCAL_PATH = /(?:[A-Za-z]:\\Users\\[^\\\s`'"]+|\/Users\/[^\/\s`'"]+|\/home\/[^\/\s`'"]+)/;
const self = path.resolve(__filename);
for (const f of scanFiles) {
  if (path.resolve(f) === self) continue;
  let text;
  try { text = fs.readFileSync(f, 'utf8'); } catch { continue; }
  for (const [re, label] of SECRETS) {
    if (re.test(text)) errors.push(`${rel(f)}: looks like a ${label}`);
  }
  const emails = (text.match(EMAIL) || []).filter((e) => !/@(example\.(com|org)|users\.noreply\.github\.com)$|noreply@/i.test(e));
  if (emails.length) warnings.push(`${rel(f)}: email address(es) ${[...new Set(emails)].slice(0, 3).join(', ')}`);
  const lp = LOCAL_PATH.exec(text);
  if (lp) warnings.push(`${rel(f)}: absolute local path ${lp[0]}`);
  if (text.includes('\r\n')) warnings.push(`${rel(f)}: CRLF line endings (project rule: LF)`);
}

// 6. .gitignore
const gi = path.join(repo, '.gitignore');
if (!fs.existsSync(gi)) {
  warnings.push('no root .gitignore');
} else {
  const g = fs.readFileSync(gi, 'utf8');
  if (/^\s*\.assist\/?\s*$/m.test(g)) warnings.push('.gitignore excludes .assist/, but the project decided .assist/ is tracked and pushed');
  for (const pat of ['.env', '*.jks', '*.keystore', 'key.properties', '*.p12', '*.mobileprovision']) {
    if (!g.includes(pat)) warnings.push(`.gitignore does not block ${pat}`);
  }
}

// 7. freshness (warnings only)
{
  const STATUS_LAG_MS = 2 * 60 * 60 * 1000;     // status.md may lag the work by 2 hours
  const CONTEXT_LAG_MS = 24 * 60 * 60 * 1000;   // a role's context.md may lag its folder by 1 day
  const mtime = (f) => fs.statSync(f).mtimeMs;
  const newest = (files) => files.reduce((a, f) => (mtime(f) > (a ? mtime(a) : 0) ? f : a), null);
  const fmt = (ms) => (ms >= 3600000 ? `${(ms / 3600000).toFixed(1)} h` : `${Math.round(ms / 60000)} min`);

  const statusFile = path.join(root, 'status.md');
  if (fs.existsSync(statusFile)) {
    const work = walk(root).filter((f) => path.resolve(f) !== path.resolve(statusFile));
    for (const sub of ['lib', 'test', 'integration_test']) work.push(...walk(path.join(repo, 'app', sub)));
    const n = newest(work);
    if (n && mtime(n) - mtime(statusFile) > STATUS_LAG_MS) {
      warnings.push(`status.md is ${fmt(mtime(n) - mtime(statusFile))} older than ${rel(n)}: update the phase, the feature table, the pending decisions and the recent changes (orchestration.md, postflight)`);
    }
    const m = /Last updated:\s*(\d{4}-\d{2}-\d{2})/.exec(fs.readFileSync(statusFile, 'utf8'));
    if (n && m) {
      const day = new Date(mtime(n)).toISOString().slice(0, 10);
      if (m[1] < day) warnings.push(`status.md says "Last updated: ${m[1]}" but ${rel(n)} changed on ${day}`);
    }
  }
  for (const role of roles) {
    const ctx = path.join(root, role, 'context.md');
    if (!fs.existsSync(ctx)) continue;
    const files = walk(path.join(root, role)).filter((f) => path.resolve(f) !== path.resolve(ctx) && !/[\/](skills|templates|prompts)[\/]/.test(f));
    const n = newest(files);
    if (n && mtime(n) - mtime(ctx) > CONTEXT_LAG_MS) {
      warnings.push(`${role}/context.md is ${fmt(mtime(n) - mtime(ctx))} older than ${rel(n)}: check that its facts and known gaps still hold`);
    }
  }
}

// report
const line = (tag, msg) => console.log(`${tag} ${msg}`);
console.log(`preflight: .assist at ${root}`);
console.log(`roles: ${roles.join(', ')}`);
for (const m of info) line('info ', m);
for (const m of warnings) line('WARN ', m);
for (const m of errors) line('ERROR', m);
console.log(errors.length ? `\nfailed: ${errors.length} error(s), ${warnings.length} warning(s)` : `\nok: no errors, ${warnings.length} warning(s)`);
process.exit(errors.length ? 1 : 0);
