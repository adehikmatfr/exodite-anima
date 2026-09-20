#!/usr/bin/env node
'use strict';
// Mutation check for controls that must not silently disappear (authorisation, privacy, migrations...).
// For each mutant: replace one exact piece of source, run the test command, and expect it to FAIL. A test suite
// that stays green with the control removed does not protect it. Files are always restored, even on Ctrl-C.
//
// Usage: node tools/mutate.js <mutants.json> [--only <text in the mutant name>]
//
// mutants.json:
// {
//   "command": ["node", "--test"],            // run once as a baseline (must pass), then once per mutant
//   "timeoutSeconds": 300,                     // a run that hangs counts as killed (for example a deadlock)
//   "mutants": [
//     { "name": "role check removed", "file": "src/server.js",
//       "find": "if (!route.roles.includes(actor.role)) {",   // must occur exactly once
//       "replace": "if (false) {",
//       "env": { "STORE": "postgres" },        // optional: environment for this mutant (and its baseline)
//       "command": ["npm", "test"] }           // optional: overrides the default command
//   ]
// }
// Exit code: 0 all mutants killed; 1 a mutant survived or a pattern was not found; 2 baseline failed.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { spawnSync } = require('node:child_process');

const args = process.argv.slice(2);
const configPath = args.find((a) => !a.startsWith('--'));
const onlyIdx = args.indexOf('--only');
const only = onlyIdx >= 0 ? args[onlyIdx + 1] : null;
if (!configPath) {
  console.error('usage: node tools/mutate.js <mutants.json> [--only <text>]');
  process.exit(64);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const root = path.dirname(path.resolve(configPath));
const timeoutMs = (config.timeoutSeconds || 300) * 1000;
const sha = (text) => crypto.createHash('sha256').update(text).digest('hex');

let current = null; // { file, original } while a mutant is applied
function restore() {
  if (current) {
    fs.writeFileSync(current.file, current.original);
    current = null;
  }
}
process.on('exit', restore);
for (const sig of ['SIGINT', 'SIGTERM']) {
  process.on(sig, () => {
    restore();
    process.exit(130);
  });
}

function run(command, env) {
  const [cmd, ...cmdArgs] = command;
  const options = { cwd: root, env: { ...process.env, ...(env || {}) }, stdio: 'ignore', timeout: timeoutMs };
  // On Windows, npm and friends are .cmd files and need a shell; a single command string avoids passing args with shell:true.
  const needsShell = process.platform === 'win32' && /^(npm|npx|yarn|pnpm)$/.test(cmd);
  const r = needsShell ? spawnSync([cmd, ...cmdArgs].join(' '), { ...options, shell: true }) : spawnSync(cmd, cmdArgs, options);
  return { code: r.status, timedOut: Boolean(r.error && r.error.code === 'ETIMEDOUT') };
}

const command = config.command;
if (!Array.isArray(command) || command.length === 0) {
  console.error('config.command must be a non-empty array');
  process.exit(64);
}
const mutants = (config.mutants || []).filter((m) => !only || m.name.includes(only));

const envs = [...new Set((config.mutants || []).map((m) => JSON.stringify(m.env || {})))].map((s) => JSON.parse(s));
for (const env of envs) {
  const base = run(command, env);
  console.log(`baseline ${JSON.stringify(env)}: ${base.code === 0 ? 'pass' : 'FAIL'}`);
  if (base.code !== 0) {
    console.error('baseline must pass before mutants mean anything');
    process.exit(2);
  }
}

const problems = [];
let killed = 0;
for (const m of mutants) {
  const file = path.resolve(root, m.file);
  const original = fs.readFileSync(file, 'utf8');
  // Patterns are written with \n; match the file's own line endings (CRLF on many Windows checkouts).
  const eol = original.includes('\r\n') ? '\r\n' : '\n';
  const find = m.find.replaceAll(/\r?\n/g, eol);
  const replacement = m.replace.replaceAll(/\r?\n/g, eol);
  const occurrences = original.split(find).length - 1;
  if (occurrences !== 1) {
    console.log(`NOT APPLIED  ${m.name}: pattern found ${occurrences} times in ${m.file} (need exactly 1)`);
    problems.push(m.name);
    continue;
  }
  current = { file, original };
  fs.writeFileSync(file, original.replace(find, () => replacement));
  let result;
  try {
    result = run(m.command || command, m.env);
  } finally {
    restore();
  }
  if (sha(fs.readFileSync(file, 'utf8')) !== sha(original)) {
    console.error(`could not restore ${m.file}`);
    process.exit(3);
  }
  const dead = result.code !== 0;
  console.log(`${dead ? 'KILLED   ' : 'SURVIVED '} ${m.name}${result.timedOut ? ' (timed out)' : ''}`);
  if (dead) killed += 1;
  else problems.push(m.name);
}

const after = run(command, (mutants[0] && mutants[0].env) || {});
console.log(`\n${killed}/${mutants.length} mutants killed; suite after restore: ${after.code === 0 ? 'pass' : 'FAIL'}`);
if (problems.length) console.log(`problems: ${problems.join('; ')}`);
process.exit(problems.length || after.code !== 0 ? 1 : 0);
