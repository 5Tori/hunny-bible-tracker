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
