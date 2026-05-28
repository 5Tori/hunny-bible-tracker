import { Alert } from '@/components/admin/ui/Alert';
import { FormField } from '@/components/admin/ui/FormField';
import { FormGrid, FormSection } from '@/components/admin/ui/FormSection';
import type { AdminPlanInput } from '@/lib/plans';

import { parseNumber } from './plan-editor-utils';

type PlanCatalogSectionProps = {
  plan: AdminPlanInput;
  onPlanChange: (next: AdminPlanInput) => void;
};

export function PlanCatalogSection({ plan, onPlanChange }: PlanCatalogSectionProps) {
  return (
    <FormSection title="Catalog">
      <FormGrid columns={2}>
        <div className="admin-checkbox-row">
          <input
            id="browse_visible"
            type="checkbox"
            checked={plan.browse_visible !== false}
            onChange={(e) => onPlanChange({ ...plan, browse_visible: e.target.checked })}
          />
          <label htmlFor="browse_visible">Show in browse catalog</label>
        </div>
        <FormField label="Featured rank" htmlFor="featured_rank" hint="Lower = earlier in Featured sort">
          <input
            id="featured_rank"
            type="number"
            min={0}
            value={plan.featured_rank ?? ''}
            onChange={(e) => {
              const v = parseNumber(e.target.value);
              onPlanChange({ ...plan, featured_rank: v === null ? null : v });
            }}
          />
        </FormField>
      </FormGrid>
      {plan.is_archived ? (
        <Alert tone="warning">
          This plan is archived. Unarchive from the Plans list before publishing again.
        </Alert>
      ) : null}
      <div className="admin-checkbox-row">
        <input
          id="published"
          type="checkbox"
          disabled={Boolean(plan.is_archived)}
          checked={Boolean(plan.is_published)}
          onChange={(e) => onPlanChange({ ...plan, is_published: e.target.checked })}
        />
        <label htmlFor="published">Published</label>
      </div>
    </FormSection>
  );
}
