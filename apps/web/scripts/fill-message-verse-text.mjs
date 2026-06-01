/**
 * Fill empty `verseText` on mock message seeds via bible-api.com (WEB, then KJV).
 *
 *   node apps/web/scripts/fill-message-verse-text.mjs
 *   node apps/web/scripts/fill-message-verse-text.mjs --limit=20
 *   node apps/web/scripts/fill-message-verse-text.mjs --dry-run
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SEED_FILES = [
  path.join(__dirname, '../src/lib/mock/fixtures/imported-message-seeds.ts'),
  path.join(__dirname, '../src/lib/mock/fixtures/hand-picked-message-seeds.ts'),
];

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const limitArg = args.find((a) => a.startsWith('--limit='));
const limit = limitArg ? Number(limitArg.split('=')[1]) : 20;

function esc(str) {
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, ' ');
}

async function fetchVerseTextOnce(verse, translation) {
  const ref = encodeURIComponent(verse.replace(/\s+/g, ' ').trim());
  const res = await fetch(`https://bible-api.com/${ref}?translation=${translation}`, {
    signal: AbortSignal.timeout(15_000),
  });
  if (res.status === 429 || !res.ok) return null;
  const data = await res.json();
  if (typeof data.text === 'string' && data.text.trim()) {
    return data.text.replace(/\n/g, ' ').replace(/\s+/g, ' ').trim();
  }
  if (Array.isArray(data.verses)) {
    const joined = data.verses.map((v) => v.text.trim()).filter(Boolean).join(' ');
    return joined || null;
  }
  return null;
}

async function resolveVerseText(verse) {
  for (const [translation, version] of [
    ['web', 'WEB'],
    ['kjv', 'KJV'],
  ]) {
    const text = await fetchVerseTextOnce(verse, translation);
    if (text) return { text, version };
    await new Promise((r) => setTimeout(r, 450));
  }
  return null;
}

function parseSeeds(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const seeds = [];
  const blockRegex = /\n  \{[\s\S]*?\n  \},/g;
  let match;
  while ((match = blockRegex.exec(content)) !== null) {
    const block = match[0];
    const slug = block.match(/slug: '([^']+)'/)?.[1];
    const verse = block.match(/verse: '((?:[^'\\]|\\.)*)'/)?.[1]?.replace(/\\'/g, "'");
    const bibleVersion = block.match(/bibleVersion: '([^']+)'/)?.[1] ?? 'WEB';
    const verseTextMatch = block.match(/verseText: '((?:[^'\\]|\\.)*)'/);
    const verseText = verseTextMatch ? verseTextMatch[1].replace(/\\'/g, "'") : '';
    seeds.push({
      slug,
      verse,
      bibleVersion,
      verseText,
      block,
      start: match.index,
      end: match.index + match[0].length,
    });
  }
  return { content, seeds };
}

function patchBlock(block, text, version) {
  let next = block;
  if (next.includes("verseText: ''")) {
    next = next.replace("verseText: ''", `verseText: '${esc(text)}'`);
  } else {
    next = next.replace(/verseText: '((?:[^'\\]|\\.)*)'/, `verseText: '${esc(text)}'`);
  }
  next = next.replace(/bibleVersion: '[^']+'/, `bibleVersion: '${version}'`);
  return next;
}

async function main() {
  let remaining = limit;
  let filled = 0;
  let failed = 0;

  for (const filePath of SEED_FILES) {
    if (remaining <= 0) break;
    const { content, seeds } = parseSeeds(filePath);
    const targets = seeds.filter((s) => s.verse && !s.verseText.trim()).slice(0, remaining);
    if (targets.length === 0) continue;

    const replacements = [];
    for (const target of targets) {
      process.stderr.write(`Fetching ${target.verse} (${target.slug})...\n`);
      const result = await resolveVerseText(target.verse);
      if (!result) {
        process.stderr.write(`  failed: ${target.slug}\n`);
        failed += 1;
        continue;
      }

      process.stderr.write(`  ok (${result.version}, ${result.text.length} chars)\n`);
      replacements.push({
        start: target.start,
        end: target.end,
        block: patchBlock(target.block, result.text, result.version),
        slug: target.slug,
      });
      filled += 1;
      remaining -= 1;
      await new Promise((r) => setTimeout(r, 350));
    }

    if (replacements.length === 0 || dryRun) continue;

    replacements.sort((a, b) => b.start - a.start);
    let nextContent = content;
    for (const rep of replacements) {
      nextContent = nextContent.slice(0, rep.start) + rep.block + nextContent.slice(rep.end);
    }
    fs.writeFileSync(filePath, nextContent);
    process.stderr.write(`Updated ${filePath} (${replacements.length} seeds)\n`);
  }

  console.log(JSON.stringify({ filled, failed, limit }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
