import { getSupabaseAdmin } from '@/lib/supabase/admin';
import type { PlanItem, PlanSection, PlanTag, PlanTemplateBase, PlanTemplateWithRelations } from '@/lib/plans';

type PlanTemplateRow = PlanTemplateBase & {
  plan_template_sections: Array<
    Omit<PlanSection, 'items'> & {
      plan_template_items: PlanItem[];
    }
  > | null;
  plan_template_tags: Array<{ plan_tags: PlanTag | null }> | null;
};

const ADMIN_PLAN_SELECT = `
  *,
  plan_template_sections (
    *,
    plan_template_items (*)
  ),
  plan_template_tags (
    plan_tags (*)
  )
`;

function mapPlanRow(row: PlanTemplateRow): PlanTemplateWithRelations {
  const sections = (row.plan_template_sections ?? [])
    .slice()
    .sort((a, b) => a.order_index - b.order_index || a.created_at.localeCompare(b.created_at))
    .map((section) => {
      const { plan_template_items, ...sectionBase } = section;
      const items = (plan_template_items ?? [])
        .slice()
        .sort((a, b) => a.order_index - b.order_index || a.created_at.localeCompare(b.created_at));
      return { ...sectionBase, items };
    });

  const tags = (row.plan_template_tags ?? [])
    .map((link) => link.plan_tags)
    .filter((tag): tag is PlanTag => tag != null)
    .sort((a, b) => a.name.localeCompare(b.name));

  const {
    plan_template_sections: _sections,
    plan_template_tags: _tags,
    ...plan
  } = row;

  return { ...plan, sections, tags };
}

export async function fetchAdminPlansViaRest(): Promise<PlanTemplateBase[]> {
  const { data, error } = await getSupabaseAdmin()
    .from('plan_templates')
    .select('*')
    .order('updated_at', { ascending: false });

  if (error) {
    throw new Error(error.message);
  }

  return (data ?? []) as PlanTemplateBase[];
}

export async function fetchAdminPlanByIdViaRest(id: string): Promise<PlanTemplateWithRelations | null> {
  const { data, error } = await getSupabaseAdmin()
    .from('plan_templates')
    .select(ADMIN_PLAN_SELECT)
    .eq('id', id)
    .maybeSingle();

  if (error) {
    throw new Error(error.message);
  }

  if (!data) {
    return null;
  }

  return mapPlanRow(data as PlanTemplateRow);
}
