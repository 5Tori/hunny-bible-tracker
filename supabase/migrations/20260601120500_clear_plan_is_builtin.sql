-- Built-in flag unused for now; treat all catalog plans like admin-created plans.
begin;

update public.plan_templates
set is_builtin = false,
    updated_at = now()
where is_builtin = true;

commit;
