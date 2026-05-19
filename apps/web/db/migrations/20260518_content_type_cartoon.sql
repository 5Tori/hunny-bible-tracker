do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'contents_content_type_check'
      and conrelid = 'contents'::regclass
  ) then
    alter table contents drop constraint contents_content_type_check;
  end if;
end $$;

update contents
set
  content_type = 'cartoon',
  updated_at = now()
where content_type = 'webtoon';

alter table contents
  add constraint contents_content_type_check
  check (content_type in ('message', 'video', 'essay', 'cartoon'));
