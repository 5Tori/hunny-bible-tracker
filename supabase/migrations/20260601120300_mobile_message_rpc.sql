-- Mobile + web read RPC: Message card library (public, read-only)

create or replace function public.mobile_message_list(
  p_language text default 'en',
  p_category text default null,
  p_situation text default null,
  p_tag text default null,
  p_tone text default null,
  p_q text default null,
  p_limit integer default 48
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_lang text;
  v_category text;
  v_situation text;
  v_tag text;
  v_tone text;
  v_q text;
  v_limit integer;
begin
  v_lang := lower(coalesce(nullif(trim(p_language), ''), 'en'));
  v_lang := left(v_lang, 16);
  v_category := nullif(lower(trim(coalesce(p_category, ''))), '');
  v_situation := nullif(lower(trim(coalesce(p_situation, ''))), '');
  v_tag := nullif(lower(trim(coalesce(p_tag, ''))), '');
  v_tone := nullif(lower(trim(coalesce(p_tone, ''))), '');
  v_q := nullif(trim(coalesce(p_q, '')), '');
  v_limit := greatest(1, least(coalesce(p_limit, 48), 100));

  return coalesce(
    (
      select jsonb_agg(row_payload order by featured_rank asc nulls last, published_at desc nulls last, updated_at desc)
      from (
        select
          c.featured_rank,
          c.published_at,
          c.updated_at,
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
            'related_plans', '[]'::jsonb
          ) as row_payload
        from public.contents c
        where c.content_type = 'message'
          and c.is_published = true
          and c.is_archived = false
          and c.browse_visible = true
          and c.language = v_lang
          and (
            v_category is null
            or exists (
              select 1
              from public.content_tag_links ctl
              join public.content_tags ct on ct.id = ctl.tag_id
              where ctl.content_id = c.id
                and ct.type = 'category'
                and ct.key = v_category
            )
          )
          and (
            v_situation is null
            or exists (
              select 1
              from public.content_tag_links ctl
              join public.content_tags ct on ct.id = ctl.tag_id
              where ctl.content_id = c.id
                and ct.type = 'situation'
                and ct.key = v_situation
            )
          )
          and (
            v_tone is null
            or exists (
              select 1
              from public.content_tag_links ctl
              join public.content_tags ct on ct.id = ctl.tag_id
              where ctl.content_id = c.id
                and ct.type = 'tone'
                and ct.key = v_tone
            )
          )
          and (
            v_tag is null
            or exists (
              select 1
              from public.content_tag_links ctl
              join public.content_tags ct on ct.id = ctl.tag_id
              where ctl.content_id = c.id
                and (
                  (ct.type = 'theme' and ct.key = v_tag)
                  or lower(ct.name) = v_tag
                )
            )
          )
          and (
            v_q is null
            or c.title ilike '%' || v_q || '%'
            or coalesce(c.subtitle, '') ilike '%' || v_q || '%'
            or coalesce(c.summary, '') ilike '%' || v_q || '%'
            or coalesce(c.primary_verse_reference, '') ilike '%' || v_q || '%'
            or coalesce(c.verse_text, '') ilike '%' || v_q || '%'
            or coalesce(c.metadata->>'shortReflection', '') ilike '%' || v_q || '%'
            or coalesce(c.metadata->>'prayerText', '') ilike '%' || v_q || '%'
            or exists (
              select 1
              from jsonb_array_elements_text(
                case
                  when jsonb_typeof(c.metadata->'searchAliases') = 'array'
                  then c.metadata->'searchAliases'
                  else '[]'::jsonb
                end
              ) alias(value)
              where alias.value ilike '%' || v_q || '%'
            )
            or exists (
              select 1
              from public.content_tag_links ctl
              join public.content_tags ct on ct.id = ctl.tag_id
              where ctl.content_id = c.id
                and ct.name ilike '%' || v_q || '%'
            )
          )
        order by c.featured_rank asc nulls last, c.published_at desc nulls last, c.updated_at desc
        limit v_limit
      ) listed
    ),
    '[]'::jsonb
  );
end;
$$;

create or replace function public.mobile_message_detail(
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
  where c.content_type = 'message'
    and c.is_published = true
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
    'assets', '[]'::jsonb,
    'sections', '[]'::jsonb,
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

revoke all on function public.mobile_message_list(text, text, text, text, text, text, integer) from public;
revoke all on function public.mobile_message_detail(text, text) from public;

grant execute on function public.mobile_message_list(text, text, text, text, text, text, integer) to anon, authenticated;
grant execute on function public.mobile_message_detail(text, text) to anon, authenticated;
