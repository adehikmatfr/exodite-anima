#!/usr/bin/env node
'use strict';
// Check the ID registry in .assist/_shared/index.md and the links between specs and tests.
// Usage: node check-registry.js [path-to-.assist] [--strict]
//   (default path: current directory, or its .assist child)
//
// Fails (exit 1) on:
//   - a registry location that does not exist, a duplicate ID, a malformed registry row;
//   - an ID used in role docs but not registered, or in a Related column but not registered;
//   - an acceptance criterion (AC-n row in a FEAT- spec) that cites no test and does not say QA will assign one;
//   - a criterion that cites a TC- missing from every test plan table, or whose test-plan row is linked to a
//     different FEAT- (the spec and the plan disagree about what the test proves).
// Warns (fails only with --strict) when a test-plan row is linked to a FEAT- but none of that FEAT-'s criteria cites it.

const fs = require('node:fs');
const path = require('node:path');

const PREFIXES = 'FEAT|ADR|TC|TP|PRR|RB|INC|RISK|THR|SLO|API|WF|MODEL|DS|RS';
const ID_RE = new RegExp(`\\b(?:${PREFIXES})-\\d{3}\\b`, 'g');
const RANGE_RE = new RegExp(`\\b(${PREFIXES})-(\\d{3})\\.\\.(\\d{1,3})\\b`, 'g');
// Directories whose examples are illustrative, not real registry usage.
const SKIP_DIRS = new Set(['skills', 'templates', 'standards', 'tools']);

const args = process.argv.slice(2);
const strict = args.includes('--strict');

function findRoot(arg) {
  const start = path.resolve(arg || '.');
  for (const c of [start, path.join(start, '.assist')]) {
    if (fs.existsSync(path.join(c, '_shared', 'index.md'))) return c;
  }
  console.error(`error: no _shared/index.md under ${start}`);
  process.exit(2);
}

function expand(text) {
  const ids = new Set();
  for (const m of text.matchAll(RANGE_RE)) {
    const width = m[2].length;
    for (let n = Number(m[2]); n <= Number(m[2].slice(0, width - m[3].length) + m[3]); n++) {
      ids.add(`${m[1]}-${String(n).padStart(width, '0')}`);
    }
  }
  for (const id of text.replace(RANGE_RE, '').match(ID_RE) || []) ids.add(id);
  return ids;
}

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (e.isDirectory()) {
      if (!SKIP_DIRS.has(e.name)) walk(path.join(dir, e.name), out);
    } else if (e.name.endsWith('.md')) out.push(path.join(dir, e.name));
  }
  return out;
}

const root = findRoot(args.find((a) => !a.startsWith('--')));
const indexPath = path.join(root, '_shared', 'index.md');
const indexText = fs.readFileSync(indexPath, 'utf8');
const problems = [];
const warnings = [];
const registered = new Map();

const section = indexText.split(/^## Registry\s*$/m)[1] || '';
for (const line of section.split('\n')) {
  if (!/^\| [A-Z]+-\d{3}/.test(line)) continue;
  const cells = line.split('|').map((c) => c.trim());
  if (cells.length !== 8) {
    // A row needs exactly 6 columns: ID, Title, Status, Owner role, Location, Related.
    problems.push(`malformed registry row (${cells.length - 2} columns, expected 6): ${line.slice(0, 70)}`);
    continue;
  }
  const [, idCell, , , , loc, related] = cells;
  const ids = expand(idCell);
  const locMatch = loc.match(/`([^`]+)`/);
  for (const id of ids) {
    if (registered.has(id)) problems.push(`duplicate ID ${id}`);
    registered.set(id, { loc: locMatch && locMatch[1], related });
  }
  if (!locMatch) problems.push(`${idCell}: no location`);
  else if (!fs.existsSync(path.join(root, locMatch[1]))) problems.push(`${idCell}: location not found: ${locMatch[1]}`);
}

for (const [id, info] of registered) {
  for (const rel of expand(info.related || '')) {
    if (!registered.has(rel)) problems.push(`${id}: related ID not registered: ${rel}`);
  }
}

const files = walk(root).filter((f) => path.resolve(f) !== path.resolve(indexPath));
for (const file of files) {
  const rel = path.relative(root, file);
  for (const id of expand(fs.readFileSync(file, 'utf8'))) {
    if (!registered.has(id)) problems.push(`${rel}: unregistered ID ${id}`);
  }
}

// ---- criterion -> test mapping (specs against the test plan)
const cellsOf = (line) => line.split('|').map((c) => c.trim());
const tcFeats = new Map(); // TC- -> Set of FEAT- ids it is linked to in a test-plan table
const specs = []; // { rel, feat, criteria: [{ ac, tcs, text }] }
for (const file of files) {
  const rel = path.relative(root, file);
  const text = fs.readFileSync(file, 'utf8');
  const feat = /^# (FEAT-\d{3})\b/m.exec(text)?.[1];
  const criteria = [];
  for (const line of text.split(/\r?\n/)) {
    if (/^\| TC-\d{3}/.test(line)) {
      // Test-plan row: | TC-nnn | title | FEAT-nnn / other IDs | level | priority | automation |
      const cells = cellsOf(line);
      const feats = [...expand(cells[3] || '')].filter((i) => i.startsWith('FEAT-'));
      for (const tc of expand(cells[1])) {
        if (!tcFeats.has(tc)) tcFeats.set(tc, new Set());
        for (const f of feats) tcFeats.get(tc).add(f);
      }
    } else if (feat && /^\| AC-\d+ \|/.test(line)) {
      const cells = cellsOf(line);
      criteria.push({ ac: cells[1], tcs: expand(cells.at(-2)), text: cells.at(-2) });
    }
  }
  if (feat) specs.push({ rel, feat, criteria });
}

const cited = new Map(); // FEAT- -> Set of TC- cited by its criteria
for (const { rel, feat, criteria } of specs) {
  cited.set(feat, new Set());
  for (const c of criteria) {
    if (c.tcs.size === 0 && !/QA will assign/i.test(c.text)) {
      problems.push(`${rel}: ${c.ac} cites no test (name a TC- or write "QA will assign")`);
    }
    for (const tc of c.tcs) {
      cited.get(feat).add(tc);
      if (tcFeats.size > 0 && !tcFeats.has(tc)) {
        problems.push(`${rel}: ${c.ac} cites ${tc}, which is in no test-plan table`);
      } else if (tcFeats.has(tc) && tcFeats.get(tc).size > 0 && !tcFeats.get(tc).has(feat)) {
        problems.push(`${rel}: ${c.ac} cites ${tc}, but the test plan links ${tc} to ${[...tcFeats.get(tc)].join(', ')}, not ${feat}`);
      }
    }
  }
}
for (const [tc, feats] of tcFeats) {
  for (const feat of feats) {
    if (cited.has(feat) && !cited.get(feat).has(tc)) warnings.push(`${tc} is linked to ${feat} in the test plan, but no criterion of ${feat} cites it`);
  }
}

if (warnings.length) console.error(warnings.map((w) => `warning: ${w}`).join('\n'));
const failing = strict ? [...problems, ...warnings.map((w) => `(strict) ${w}`)] : problems;
if (failing.length) {
  console.error(failing.map((p) => `- ${p}`).join('\n'));
  console.error(`\n${failing.length} problem(s); ${registered.size} IDs registered`);
  process.exit(1);
}
const criteriaCount = specs.reduce((n, s) => n + s.criteria.length, 0);
console.log(`ok: ${registered.size} IDs registered, all locations exist, no unregistered references; ${criteriaCount} criteria in ${specs.length} specs map to known tests${warnings.length ? ` (${warnings.length} warning(s))` : ''}`);
