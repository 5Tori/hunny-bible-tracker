-- Discover-only default for mobile_content_list; richer Today linked_content for message cards.

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
      select jsonb_agg(row_payload order by
        case when p_sort = 'new' then published_at end desc nulls last,
        case when p_sort <> 'new' then featured_rank end asc nulls last,
        updated_at desc
      )
      from (
        select
          c.published_at,
          c.updated_at,
          c.featured_rank,
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
          and (
            case
              when v_type = 'message' then c.content_type = 'message'
              when v_type is not null then c.content_type = v_type
              else c.content_type in ('video', 'essay', 'cartoon')
            end
          )
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
  v_context text;
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
  v_context := null;
  if v_message.content_id is not null then
    select jsonb_build_object(
      'id', c.id,
      'slug', c.slug,
      'content_type', c.content_type,
      'title', c.title,
      'summary', case when c.content_type = 'message' then null else c.summary end,
      'context', nullif(trim(coalesce(c.metadata->>'context', '')), ''),
      'cover_image_url', c.cover_image_url,
      'messages_url', case when c.content_type = 'message' then '/messages/' || c.slug else null end,
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
    ),
    nullif(trim(coalesce(c.metadata->>'context', '')), '')
    into v_linked, v_context
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
    'context', v_context,
    'is_published', v_message.is_published,
    'heart_count', v_message.heart_count,
    'share_count', v_message.share_count,
    'created_at', v_message.created_at,
    'updated_at', v_message.updated_at,
    'linked_content', v_linked
  );
end;
$$;

revoke all on function public.mobile_content_list(text, text, text, text, integer) from public;
grant execute on function public.mobile_content_list(text, text, text, text, integer) to anon, authenticated;

revoke all on function public.mobile_today_message_latest(text, date) from public;
grant execute on function public.mobile_today_message_latest(text, date) to anon, authenticated;
