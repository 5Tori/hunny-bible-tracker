-- Security hardening: lock down internal functions, optimize profiles RLS, add FK index.
-- Applied on remote as migration version 20260530041935.

revoke all on function public.handle_new_user() from public;
revoke all on function public.handle_new_user() from anon, authenticated;

revoke all on function public.rls_auto_enable() from public;
revoke all on function public.rls_auto_enable() from anon, authenticated;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using ((select auth.uid()) = id);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create index if not exists idx_plan_template_tags_tag_id
  on public.plan_template_tags (tag_id);
