-- Hunny Bible Tracker server schema (Supabase).
-- Supabase Auth owns identity (auth.users). public.profiles stores app metadata behind Next.js API routes.
-- Prefer applying supabase/migrations/20260528000000_baseline.sql via Supabase CLI or dashboard.

create extension if not exists pgcrypto with schema extensions;

create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  photo_url text,
  email_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_seen_at timestamptz
);

create table if not exists plan_templates (
  id uuid primary key default gen_random_uuid(),
  template_key text not null unique,
  title text not null,
  subtitle text,
  short_description text,
  description text,
  cover_image_url text,
  cover_image_public_id text,
  plan_type text,
  testament_scope text,
  difficulty text,
  estimated_minutes integer,
  estimated_days integer,
  total_chapters integer,
  primary_book_key text,
  primary_character text,
  is_builtin boolean not null default false,
  is_published boolean not null default false,
  is_archived boolean not null default false,
  featured_rank integer,
  browse_visible boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_plan_templates_published_updated
  on plan_templates (is_published, updated_at desc);

create index if not exists idx_plan_templates_archived_published
  on plan_templates (is_archived, is_published, updated_at desc);

create index if not exists idx_plan_templates_browse_featured
  on plan_templates (browse_visible, featured_rank, updated_at desc);

create table if not exists plan_template_sections (
  id uuid primary key default gen_random_uuid(),
  plan_template_id uuid not null references plan_templates(id) on delete cascade,
  section_key text not null,
  title text not null,
  description text,
  order_index integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (plan_template_id, section_key)
);

create index if not exists idx_plan_template_sections_plan_order
  on plan_template_sections (plan_template_id, order_index);

create table if not exists plan_template_items (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references plan_template_sections(id) on delete cascade,
  order_index integer not null default 0,
  book_key text not null,
  start_chapter integer not null default 1,
  end_chapter integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_chapter >= 1),
  check (end_chapter >= start_chapter)
);

create index if not exists idx_plan_template_items_section_order
  on plan_template_items (section_id, order_index);

create table if not exists plan_tags (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  name text not null,
  type text,
  created_at timestamptz not null default now()
);

create table if not exists plan_template_tags (
  plan_template_id uuid not null references plan_templates(id) on delete cascade,
  tag_id uuid not null references plan_tags(id) on delete cascade,
  primary key (plan_template_id, tag_id)
);

create table if not exists user_reading_backups (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references profiles(id) on delete cascade,
  backup_version integer not null,
  payload_jsonb jsonb not null,
  payload_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (auth_user_id),
  check (backup_version >= 1),
  check (jsonb_typeof(payload_jsonb) = 'object')
);

create index if not exists idx_user_reading_backups_updated
  on user_reading_backups (updated_at desc);

create table if not exists media_assets (
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  public_id text not null,
  secure_url text not null,
  resource_type text,
  folder text,
  width integer,
  height integer,
  bytes integer,
  format text,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_media_assets_provider_public_id
  on media_assets (provider, public_id);

create table if not exists content_authors (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  display_name text not null,
  bio text,
  avatar_image_url text,
  avatar_image_public_id text,
  website_url text,
  is_verified boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (char_length(slug) between 1 and 120),
  check (char_length(display_name) between 1 and 160)
);

create index if not exists idx_content_authors_active_name
  on content_authors (is_active, display_name);

create index if not exists idx_content_authors_verified_active
  on content_authors (is_verified, is_active, display_name);

create table if not exists contents (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  content_type text not null,
  language text not null default 'en',
  title text not null,
  subtitle text,
  summary text,
  body text,
  cover_image_url text,
  cover_image_public_id text,
  author_id uuid references content_authors(id) on delete set null,
  primary_verse_reference text,
  bible_version text,
  verse_text text,
  duration_seconds integer,
  external_url text,
  is_published boolean not null default false,
  is_archived boolean not null default false,
  published_at timestamptz,
  featured_rank integer,
  browse_visible boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (content_type in ('message', 'video', 'essay', 'cartoon')),
  check (char_length(slug) between 1 and 160),
  check (char_length(title) between 1 and 240),
  check (duration_seconds is null or duration_seconds >= 0),
  check (jsonb_typeof(metadata) = 'object')
);

create index if not exists idx_contents_published_lookup
  on contents (is_published, is_archived, browse_visible, published_at desc);

create index if not exists idx_contents_type_published
  on contents (content_type, is_published, published_at desc);

create index if not exists idx_contents_featured
  on contents (browse_visible, featured_rank, published_at desc);

create index if not exists idx_contents_author
  on contents (author_id, published_at desc);

create table if not exists content_assets (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references contents(id) on delete cascade,
  asset_type text not null,
  asset_role text not null default 'body',
  order_index integer not null default 0,
  title text,
  caption text,
  alt_text text,
  url text not null,
  public_id text,
  provider text,
  mime_type text,
  width integer,
  height integer,
  duration_seconds integer,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (order_index >= 0),
  check (duration_seconds is null or duration_seconds >= 0),
  check (jsonb_typeof(metadata) = 'object')
);

create index if not exists idx_content_assets_content_order
  on content_assets (content_id, asset_role, order_index);

create table if not exists content_sections (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references contents(id) on delete cascade,
  order_index integer not null default 0,
  title text,
  body text,
  image_url text,
  image_public_id text,
  image_alt_text text,
  image_caption text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (order_index >= 0),
  check (jsonb_typeof(metadata) = 'object')
);

create index if not exists idx_content_sections_content_order
  on content_sections (content_id, order_index);

create table if not exists content_tags (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  key text not null,
  name text not null,
  description text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (type, key),
  check (char_length(type) between 1 and 80),
  check (char_length(key) between 1 and 120),
  check (char_length(name) between 1 and 160)
);

create index if not exists idx_content_tags_type_sort
  on content_tags (type, is_active, sort_order, name);

create table if not exists content_tag_links (
  content_id uuid not null references contents(id) on delete cascade,
  tag_id uuid not null references content_tags(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (content_id, tag_id)
);

create index if not exists idx_content_tag_links_tag
  on content_tag_links (tag_id, content_id);

create table if not exists content_plan_links (
  content_id uuid not null references contents(id) on delete cascade,
  plan_template_id uuid not null references plan_templates(id) on delete cascade,
  relationship_type text not null default 'related',
  display_order integer not null default 0,
  cta_label text,
  created_at timestamptz not null default now(),
  primary key (content_id, plan_template_id, relationship_type),
  check (display_order >= 0)
);

create index if not exists idx_content_plan_links_content_order
  on content_plan_links (content_id, display_order);

create index if not exists idx_content_plan_links_plan
  on content_plan_links (plan_template_id, content_id);

create table if not exists today_messages (
  id uuid primary key default gen_random_uuid(),
  content_id uuid references contents(id) on delete set null,
  publish_date date not null,
  language text not null default 'en',
  verse_reference text not null,
  bible_version text,
  verse_text text,
  image_url text,
  image_public_id text,
  share_image_url text,
  share_image_public_id text,
  hint_title text,
  hint_summary text,
  is_published boolean not null default false,
  heart_count integer not null default 0,
  share_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (publish_date, language)
);

create index if not exists idx_today_messages_publish_lang
  on today_messages (language, publish_date desc);

create index if not exists idx_today_messages_published_lookup
  on today_messages (is_published, language, publish_date desc);

create index if not exists idx_today_messages_engagement
  on today_messages (heart_count desc, share_count desc);

create index if not exists idx_today_messages_content
  on today_messages (content_id);

create table if not exists feedback_messages (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  message text not null,
  contact_email text,
  signed_in_email text,
  source text not null default 'mobile_settings',
  app_version text,
  platform text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  check (category in ('bug', 'idea', 'other')),
  check (char_length(message) between 1 and 1000)
);

create index if not exists idx_feedback_messages_created
  on feedback_messages (created_at desc);

create index if not exists idx_feedback_messages_category_created
  on feedback_messages (category, created_at desc);
-- Mobile read RPC: Today's Message (public, read-only)

create or replace function public.mobile_today_message_latest(
  p_language text,
  p_date date default current_date
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lang text;
  v_message public.today_messages%rowtype;
  v_linked jsonb;
begin
  v_lang := lower(coalesce(nullif(trim(p_language), ''), 'en'));
  v_lang := left(v_lang, 16);

  select *
  into v_message
  from public.today_messages
  where is_published = true
    and language = v_lang
    and publish_date <= p_date
  order by publish_date desc, updated_at desc
  limit 1;

  if not found then
    return null;
  end if;

  v_linked := null;
  if v_message.content_id is not null then
    select jsonb_build_object(
      'id', c.id,
      'slug', c.slug,
      'content_type', c.content_type,
      'title', c.title,
      'summary', c.summary,
      'cover_image_url', c.cover_image_url,
      'related_plans', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'id', pt.id,
              'template_key', pt.template_key,
              'title', pt.title,
              'total_chapters', pt.total_chapters,
              'estimated_minutes', pt.estimated_minutes,
              'cta_label', cpl.cta_label
            )
            order by cpl.display_order asc, pt.featured_rank asc nulls last, pt.updated_at desc
          )
          from public.content_plan_links cpl
          join public.plan_templates pt on pt.id = cpl.plan_template_id
            and pt.is_published = true
            and pt.is_archived = false
          where cpl.content_id = c.id
        ),
        '[]'::jsonb
      )
    )
    into v_linked
    from public.contents c
    where c.id = v_message.content_id
      and c.is_published = true
      and c.is_archived = false;
  end if;

  return jsonb_build_object(
    'id', v_message.id,
    'content_id', v_message.content_id,
    'publish_date', to_char(v_message.publish_date, 'YYYY-MM-DD'),
    'language', v_message.language,
    'verse_reference', v_message.verse_reference,
    'bible_version', v_message.bible_version,
    'verse_text', v_message.verse_text,
    'image_url', v_message.image_url,
    'image_public_id', v_message.image_public_id,
    'share_image_url', v_message.share_image_url,
    'share_image_public_id', v_message.share_image_public_id,
    'hint_title', v_message.hint_title,
    'hint_summary', v_message.hint_summary,
    'is_published', v_message.is_published,
    'heart_count', v_message.heart_count,
    'share_count', v_message.share_count,
    'created_at', v_message.created_at,
    'updated_at', v_message.updated_at,
    'linked_content', v_linked
  );
end;
$$;

revoke all on function public.mobile_today_message_latest(text, date) from public;
grant execute on function public.mobile_today_message_latest(text, date) to anon, authenticated;
-- Mobile read RPC: Discover content + plan catalog (public, read-only)

create or replace function public.mobile_content_list(
  p_language text default 'en',
  p_sort text default 'featured',
  p_type text default null,
  p_tag text default null,
  p_limit integer default 20
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lang text;
  v_limit integer;
  v_type text;
  v_tag text;
begin
  v_lang := lower(coalesce(nullif(trim(p_language), ''), 'en'));
  v_lang := left(v_lang, 16);
  v_limit := greatest(1, least(coalesce(p_limit, 20), 50));
  v_type := nullif(lower(trim(coalesce(p_type, ''))), '');
  v_tag := nullif(lower(trim(coalesce(p_tag, ''))), '');

  return coalesce(
    (
      select jsonb_agg(row_payload order by sort_rank asc nulls last, published_at desc nulls last, updated_at desc)
      from (
        select
          c.published_at,
          c.updated_at,
          case when p_sort = 'new' then c.published_at else c.featured_rank end as sort_rank,
          jsonb_build_object(
            'id', c.id,
            'slug', c.slug,
            'content_type', c.content_type,
            'language', c.language,
            'title', c.title,
            'subtitle', c.subtitle,
            'summary', c.summary,
            'body', null,
            'cover_image_url', c.cover_image_url,
            'cover_image_public_id', c.cover_image_public_id,
            'author_id', c.author_id,
            'primary_verse_reference', c.primary_verse_reference,
            'bible_version', c.bible_version,
            'verse_text', c.verse_text,
            'duration_seconds', c.duration_seconds,
            'external_url', c.external_url,
            'is_published', c.is_published,
            'is_archived', c.is_archived,
            'published_at', c.published_at,
            'featured_rank', c.featured_rank,
            'browse_visible', c.browse_visible,
            'metadata', coalesce(c.metadata, '{}'::jsonb),
            'created_at', c.created_at,
            'updated_at', c.updated_at,
            'author', (
              select to_jsonb(a.*)
              from public.content_authors a
              where a.id = c.author_id
              limit 1
            ),
            'assets', '[]'::jsonb,
            'sections', '[]'::jsonb,
            'tags', coalesce(
              (
                select jsonb_agg(to_jsonb(t.*) order by t.type asc, t.sort_order asc, t.name asc)
                from public.content_tag_links ctl
                join public.content_tags t on t.id = ctl.tag_id
                where ctl.content_id = c.id
              ),
              '[]'::jsonb
            ),
            'related_plans', coalesce(
              (
                select jsonb_agg(
                  jsonb_build_object(
                    'relationship_type', cpl.relationship_type,
                    'display_order', cpl.display_order,
                    'cta_label', cpl.cta_label,
                    'id', pt.id,
                    'template_key', pt.template_key,
                    'title', pt.title,
                    'subtitle', pt.subtitle,
                    'cover_image_url', pt.cover_image_url,
                    'total_chapters', pt.total_chapters,
                    'estimated_minutes', pt.estimated_minutes
                  )
                  order by cpl.display_order asc, pt.featured_rank asc nulls last, pt.updated_at desc
                )
                from public.content_plan_links cpl
                join public.plan_templates pt on pt.id = cpl.plan_template_id
                  and pt.is_published = true
                  and pt.is_archived = false
                where cpl.content_id = c.id
              ),
              '[]'::jsonb
            )
          ) as row_payload
        from public.contents c
        left join public.content_tag_links ctl on ctl.content_id = c.id
        left join public.content_tags ct on ct.id = ctl.tag_id
        where c.is_published = true
          and c.is_archived = false
          and c.browse_visible = true
          and c.language = v_lang
          and (v_type is null or c.content_type = v_type)
          and (
            v_tag is null
            or ct.key = v_tag
            or lower(ct.name) = v_tag
          )
        group by c.id
        order by
          case when p_sort = 'new' then c.published_at end desc nulls last,
          case when p_sort <> 'new' then c.featured_rank end asc nulls last,
          c.updated_at desc
        limit v_limit
      ) listed
    ),
    '[]'::jsonb
  );
end;
$$;

create or replace function public.mobile_content_detail(
  p_identifier text,
  p_language text default 'en'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lang text;
  v_identifier text;
  v_content public.contents%rowtype;
begin
  v_lang := lower(coalesce(nullif(trim(p_language), ''), 'en'));
  v_lang := left(v_lang, 16);
  v_identifier := trim(coalesce(p_identifier, ''));

  if v_identifier = '' then
    return null;
  end if;

  select *
  into v_content
  from public.contents c
  where c.is_published = true
    and c.is_archived = false
    and c.browse_visible = true
    and c.language = v_lang
    and (c.id::text = v_identifier or c.slug = v_identifier)
  limit 1;

  if not found then
    return null;
  end if;

  return jsonb_build_object(
    'id', v_content.id,
    'slug', v_content.slug,
    'content_type', v_content.content_type,
    'language', v_content.language,
    'title', v_content.title,
    'subtitle', v_content.subtitle,
    'summary', v_content.summary,
    'body', v_content.body,
    'cover_image_url', v_content.cover_image_url,
    'cover_image_public_id', v_content.cover_image_public_id,
    'author_id', v_content.author_id,
    'primary_verse_reference', v_content.primary_verse_reference,
    'bible_version', v_content.bible_version,
    'verse_text', v_content.verse_text,
    'duration_seconds', v_content.duration_seconds,
    'external_url', v_content.external_url,
    'is_published', v_content.is_published,
    'is_archived', v_content.is_archived,
    'published_at', v_content.published_at,
    'featured_rank', v_content.featured_rank,
    'browse_visible', v_content.browse_visible,
    'metadata', coalesce(v_content.metadata, '{}'::jsonb),
    'created_at', v_content.created_at,
    'updated_at', v_content.updated_at,
    'author', (
      select to_jsonb(a.*)
      from public.content_authors a
      where a.id = v_content.author_id
      limit 1
    ),
    'assets', coalesce(
      (
        select jsonb_agg(to_jsonb(ca.*) order by ca.asset_role asc, ca.order_index asc, ca.created_at asc)
        from public.content_assets ca
        where ca.content_id = v_content.id
      ),
      '[]'::jsonb
    ),
    'sections', coalesce(
      (
        select jsonb_agg(to_jsonb(cs.*) order by cs.order_index asc, cs.created_at asc)
        from public.content_sections cs
        where cs.content_id = v_content.id
      ),
      '[]'::jsonb
    ),
    'tags', coalesce(
      (
        select jsonb_agg(to_jsonb(t.*) order by t.type asc, t.sort_order asc, t.name asc)
        from public.content_tag_links ctl
        join public.content_tags t on t.id = ctl.tag_id
        where ctl.content_id = v_content.id
      ),
      '[]'::jsonb
    ),
    'related_plans', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'relationship_type', cpl.relationship_type,
            'display_order', cpl.display_order,
            'cta_label', cpl.cta_label,
            'id', pt.id,
            'template_key', pt.template_key,
            'title', pt.title,
            'subtitle', pt.subtitle,
            'cover_image_url', pt.cover_image_url,
            'total_chapters', pt.total_chapters,
            'estimated_minutes', pt.estimated_minutes
          )
          order by cpl.display_order asc, pt.featured_rank asc nulls last, pt.updated_at desc
        )
        from public.content_plan_links cpl
        join public.plan_templates pt on pt.id = cpl.plan_template_id
          and pt.is_published = true
          and pt.is_archived = false
        where cpl.content_id = v_content.id
      ),
      '[]'::jsonb
    )
  );
end;
$$;

create or replace function public.mobile_plan_catalog(
  p_sort text default 'featured'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  return coalesce(
    (
      select jsonb_agg(to_jsonb(pt.*) order by sort_rank asc nulls last, updated_at desc)
      from (
        select
          pt.*,
          case
            when p_sort = 'new' then pt.created_at
            when p_sort = 'popular' then pt.total_chapters
            else pt.featured_rank
          end as sort_rank
        from public.plan_templates pt
        where pt.is_published = true
          and pt.is_archived = false
          and pt.browse_visible = true
        order by
          case when p_sort = 'new' then pt.created_at end desc,
          case when p_sort = 'popular' then pt.total_chapters end desc nulls last,
          case when p_sort not in ('new', 'popular') then pt.featured_rank end asc nulls last,
          pt.updated_at desc
      ) pt
    ),
    '[]'::jsonb
  );
end;
$$;

create or replace function public.mobile_plan_detail(
  p_identifier text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_identifier text;
  v_plan public.plan_templates%rowtype;
begin
  v_identifier := trim(coalesce(p_identifier, ''));
  if v_identifier = '' then
    return null;
  end if;

  select *
  into v_plan
  from public.plan_templates pt
  where pt.is_published = true
    and pt.is_archived = false
    and pt.browse_visible = true
    and (pt.id::text = v_identifier or pt.template_key = v_identifier)
  limit 1;

  if not found then
    return null;
  end if;

  return jsonb_build_object(
    'id', v_plan.id,
    'template_key', v_plan.template_key,
    'title', v_plan.title,
    'subtitle', v_plan.subtitle,
    'short_description', v_plan.short_description,
    'description', v_plan.description,
    'cover_image_url', v_plan.cover_image_url,
    'cover_image_public_id', v_plan.cover_image_public_id,
    'plan_type', v_plan.plan_type,
    'testament_scope', v_plan.testament_scope,
    'difficulty', v_plan.difficulty,
    'estimated_minutes', v_plan.estimated_minutes,
    'estimated_days', v_plan.estimated_days,
    'total_chapters', v_plan.total_chapters,
    'primary_book_key', v_plan.primary_book_key,
    'primary_character', v_plan.primary_character,
    'is_builtin', v_plan.is_builtin,
    'is_published', v_plan.is_published,
    'is_archived', v_plan.is_archived,
    'featured_rank', v_plan.featured_rank,
    'browse_visible', v_plan.browse_visible,
    'created_at', v_plan.created_at,
    'updated_at', v_plan.updated_at,
    'sections', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'id', s.id,
            'plan_template_id', s.plan_template_id,
            'section_key', s.section_key,
            'title', s.title,
            'description', s.description,
            'order_index', s.order_index,
            'created_at', s.created_at,
            'updated_at', s.updated_at,
            'items', coalesce(
              (
                select jsonb_agg(to_jsonb(i.*) order by i.order_index asc, i.created_at asc)
                from public.plan_template_items i
                where i.section_id = s.id
              ),
              '[]'::jsonb
            )
          )
          order by s.order_index asc, s.created_at asc
        )
        from public.plan_template_sections s
        where s.plan_template_id = v_plan.id
      ),
      '[]'::jsonb
    ),
    'tags', coalesce(
      (
        select jsonb_agg(to_jsonb(t.*) order by t.name asc)
        from public.plan_template_tags ptt
        join public.plan_tags t on t.id = ptt.tag_id
        where ptt.plan_template_id = v_plan.id
      ),
      '[]'::jsonb
    )
  );
end;
$$;

revoke all on function public.mobile_content_list(text, text, text, text, integer) from public;
revoke all on function public.mobile_content_detail(text, text) from public;
revoke all on function public.mobile_plan_catalog(text) from public;
revoke all on function public.mobile_plan_detail(text) from public;

grant execute on function public.mobile_content_list(text, text, text, text, integer) to anon, authenticated;
grant execute on function public.mobile_content_detail(text, text) to anon, authenticated;
grant execute on function public.mobile_plan_catalog(text) to anon, authenticated;
grant execute on function public.mobile_plan_detail(text) to anon, authenticated;
