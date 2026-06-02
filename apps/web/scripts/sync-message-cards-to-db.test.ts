import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import postgres from 'postgres';
import { describe, expect, it } from 'vitest';

import { mergeContentMetadataWithMessage, parseMessageMetadata } from '@/lib/message-metadata';
import { handPickedMessageSeeds } from '@/lib/mock/fixtures/hand-picked-message-seeds';
import { importedMessageSeeds } from '@/lib/mock/fixtures/imported-message-seeds';
import { buildMessageContent } from '@/lib/mock/fixtures/message-card-seed-builders';

const WRITE = process.env.SYNC_MESSAGE_CARDS_WRITE === '1';
const ENV_LOCAL = join(process.cwd(), '.env.local');

function loadDatabaseUrl() {
  if (process.env.DATABASE_URL?.trim()) {
    return normalizePoolerUrl(process.env.DATABASE_URL.trim());
  }
  if (!existsSync(ENV_LOCAL)) {
    throw new Error('Set DATABASE_URL or create apps/web/.env.local');
  }
  for (const line of readFileSync(ENV_LOCAL, 'utf8').split('\n')) {
    const match = line.match(/^DATABASE_URL="(.*)"\s*$/);
    if (match) return normalizePoolerUrl(match[1]);
  }
  throw new Error('DATABASE_URL not found in apps/web/.env.local');
}

function normalizePoolerUrl(url: string) {
  if (!url.includes(':6543/') || url.includes('pgbouncer=true')) return url;
  return `${url}${url.includes('?') ? '&' : '?'}pgbouncer=true`;
}

const messageSeeds = [...handPickedMessageSeeds, ...importedMessageSeeds];
const builtCards = messageSeeds.map(buildMessageContent);

describe('sync message cards to db', () => {
  it('reports fixture vs database counts', async () => {
    const databaseUrl = loadDatabaseUrl();
    const sql = postgres(databaseUrl, { max: 1, prepare: false, ssl: 'require' });

    try {
      const [{ count }] = (await sql`
        select count(*)::int as count
        from contents
        where content_type = 'message'
      `) as Array<{ count: number }>;

      const fixtureSlugs = new Set(builtCards.map((card) => card.slug));
      const missing = (await sql`
        select slug
        from contents
        where content_type = 'message'
          and slug not in ${sql([...fixtureSlugs])}
      `) as Array<{ slug: string }>;

      console.log(`Fixture message cards: ${builtCards.length}`);
      console.log(`Database message cards: ${count}`);
      console.log(`Missing from DB (fixture slugs): ${builtCards.length - (count - missing.length)}`);

      if (!WRITE) {
        console.log('Dry run. Re-run with SYNC_MESSAGE_CARDS_WRITE=1 to upsert fixture cards.');
      }

      expect(builtCards.length).toBeGreaterThan(0);
    } finally {
      await sql.end({ timeout: 5 });
    }
  });

  it.runIf(WRITE)('upserts all fixture message cards', async () => {
    const databaseUrl = loadDatabaseUrl();
    const sql = postgres(databaseUrl, { max: 1, prepare: false, ssl: 'require' });

    try {
      const authors = (await sql`
        select id from content_authors where slug = 'hunny-team' limit 1
      `) as Array<{ id: string }>;
      const authorId = authors[0]?.id;
      if (!authorId) {
        throw new Error('Missing content_authors row for slug hunny-team — run content_test_seed.sql first.');
      }

      const tagRows = (await sql`
        select id, type, key from content_tags where is_active = true
      `) as Array<{ id: string; type: string; key: string }>;
      const tagIdByKey = new Map(tagRows.map((row) => [`${row.type}:${row.key}`, row.id]));

      const planRows = (await sql`
        select id, template_key from plan_templates
      `) as Array<{ id: string; template_key: string }>;
      const planIdByKey = new Map(planRows.map((row) => [row.template_key, row.id]));

      let upserted = 0;
      let tagLinks = 0;
      let planLinks = 0;
      let skippedTags = 0;

      await sql.begin(async (txn) => {
        for (const card of builtCards) {
          const metadata = mergeContentMetadataWithMessage(
            card.metadata ?? {},
            parseMessageMetadata(card.metadata ?? {}),
          ) as Record<string, unknown>;

          const rows = await txn<Array<{ id: string }>>`
            insert into contents (
              slug,
              content_type,
              language,
              title,
              subtitle,
              summary,
              body,
              cover_image_url,
              cover_image_public_id,
              author_id,
              primary_verse_reference,
              bible_version,
              verse_text,
              duration_seconds,
              external_url,
              is_published,
              is_archived,
              published_at,
              featured_rank,
              browse_visible,
              metadata,
              created_at,
              updated_at
            ) values (
              ${card.slug},
              'message',
              ${card.language},
              ${card.title},
              ${card.subtitle},
              ${card.summary},
              ${card.body},
              ${card.cover_image_url},
              ${card.cover_image_public_id},
              ${authorId},
              ${card.primary_verse_reference},
              ${card.bible_version},
              ${card.verse_text},
              ${card.duration_seconds},
              ${card.external_url},
              ${card.is_published},
              ${card.is_archived},
              ${card.published_at ?? new Date().toISOString()},
              ${card.featured_rank},
              ${card.browse_visible},
              ${txn.json(JSON.parse(JSON.stringify(metadata)))},
              now(),
              now()
            )
            on conflict (slug) do update set
              content_type = excluded.content_type,
              language = excluded.language,
              title = excluded.title,
              subtitle = excluded.subtitle,
              summary = excluded.summary,
              body = excluded.body,
              cover_image_url = excluded.cover_image_url,
              cover_image_public_id = excluded.cover_image_public_id,
              author_id = excluded.author_id,
              primary_verse_reference = excluded.primary_verse_reference,
              bible_version = excluded.bible_version,
              verse_text = excluded.verse_text,
              is_published = excluded.is_published,
              is_archived = excluded.is_archived,
              featured_rank = excluded.featured_rank,
              browse_visible = excluded.browse_visible,
              metadata = excluded.metadata,
              updated_at = now()
            returning id
          `;

          const contentId = rows[0]?.id;
          if (!contentId) continue;
          upserted += 1;

          await txn`
            delete from content_tag_links
            where content_id = ${contentId}
          `;

          for (const tag of card.tags) {
            const tagId = tagIdByKey.get(`${tag.type}:${tag.key}`);
            if (!tagId) {
              skippedTags += 1;
              continue;
            }
            await txn`
              insert into content_tag_links (content_id, tag_id, created_at)
              values (${contentId}, ${tagId}, now())
              on conflict (content_id, tag_id) do nothing
            `;
            tagLinks += 1;
          }

          await txn`
            delete from content_plan_links
            where content_id = ${contentId} and relationship_type = 'related'
          `;

          for (const [index, plan] of card.related_plans.entries()) {
            const planId = planIdByKey.get(plan.template_key);
            if (!planId) continue;

            await txn`
              insert into content_plan_links (
                content_id,
                plan_template_id,
                relationship_type,
                display_order,
                cta_label,
                created_at
              ) values (
                ${contentId},
                ${planId},
                'related',
                ${index},
                ${plan.cta_label ?? 'Start plan'},
                now()
              )
              on conflict (content_id, plan_template_id, relationship_type) do update set
                display_order = excluded.display_order,
                cta_label = excluded.cta_label
            `;
            planLinks += 1;
          }
        }
      });

      const [{ count }] = (await sql`
        select count(*)::int as count
        from contents
        where content_type = 'message'
      `) as Array<{ count: number }>;

      console.log(`Upserted ${upserted} fixture cards (${tagLinks} tag links, ${planLinks} plan links).`);
      if (skippedTags > 0) {
        console.log(`Skipped ${skippedTags} tag links — run supabase/seeds/message_taxonomy_seed.sql first.`);
      }
      console.log(`Total message cards in database: ${count}`);

      expect(upserted).toBe(builtCards.length);
    } finally {
      await sql.end({ timeout: 5 });
    }
  }, 300_000);
});
