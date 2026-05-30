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
