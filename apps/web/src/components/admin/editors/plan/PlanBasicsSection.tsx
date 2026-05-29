import { BookKeyCombobox } from '@/components/admin/BookKeyCombobox';
import { FormField } from '@/components/admin/ui/FormField';
import { FormGrid, FormSection } from '@/components/admin/ui/FormSection';
import type { AdminPlanInput } from '@/lib/plans';
import {
  DIFFICULTY_OPTIONS,
  PLAN_TYPE_OPTIONS,
  TESTAMENT_SCOPE_OPTIONS,
} from '@/lib/plan-taxonomy';

import { parseNumber } from './plan-editor-utils';

type PlanBasicsSectionProps = {
  plan: AdminPlanInput;
  tagsString: string;
  uploading: boolean;
  onPlanChange: (next: AdminPlanInput) => void;
  onTagsChange: (value: string) => void;
  onUpload: (file: File) => void;
};

export function PlanBasicsSection({
  plan,
  tagsString,
  uploading,
  onPlanChange,
  onTagsChange,
  onUpload,
}: PlanBasicsSectionProps) {
  return (
    <FormSection title="Basics">
      <FormField label="Title" htmlFor="title">
        <input
          id="title"
          value={plan.title}
          onChange={(e) => onPlanChange({ ...plan, title: e.target.value })}
          placeholder="Plan title"
        />
      </FormField>
      <FormField label="Subtitle" htmlFor="subtitle">
        <input
          id="subtitle"
          value={plan.subtitle ?? ''}
          onChange={(e) => onPlanChange({ ...plan, subtitle: e.target.value })}
        />
      </FormField>
      <FormField label="Short description" htmlFor="short_description">
        <textarea
          id="short_description"
          value={plan.short_description ?? ''}
          onChange={(e) => onPlanChange({ ...plan, short_description: e.target.value })}
        />
      </FormField>
      <FormField label="Full description" htmlFor="description">
        <textarea
          id="description"
          rows={4}
          value={plan.description ?? ''}
          onChange={(e) => onPlanChange({ ...plan, description: e.target.value })}
        />
      </FormField>
      <FormField label="Cover image URL" htmlFor="cover_image_url">
        <input
          id="cover_image_url"
          value={plan.cover_image_url ?? ''}
          onChange={(e) => onPlanChange({ ...plan, cover_image_url: e.target.value })}
        />
        {plan.cover_image_url ? (
          <img src={plan.cover_image_url} alt="Cover preview" className="admin-cover-preview" />
        ) : null}
      </FormField>
      <FormField label="Upload cover" htmlFor="cover_upload" hint="Images upload to Cloudinary.">
        <div className="admin-upload-box">
          <input
            id="cover_upload"
            type="file"
            accept="image/*"
            onChange={(e) => {
              const file = e.target.files?.[0];
              if (file) onUpload(file);
            }}
          />
          {uploading ? <p className="admin-muted">Uploading…</p> : null}
        </div>
      </FormField>
      <FormField label="Plan type" htmlFor="plan_type">
        <select
          id="plan_type"
          value={plan.plan_type ?? ''}
          onChange={(e) => onPlanChange({ ...plan, plan_type: e.target.value })}
          required
        >
          {PLAN_TYPE_OPTIONS.map((option) => (
            <option key={option.value || 'unset'} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      </FormField>
      <FormGrid columns={2}>
        <FormField label="Testament scope" htmlFor="testament_scope">
          <select
            id="testament_scope"
            value={plan.testament_scope ?? ''}
            onChange={(e) => onPlanChange({ ...plan, testament_scope: e.target.value })}
          >
            {TESTAMENT_SCOPE_OPTIONS.map((option) => (
              <option key={option.value || 'unset'} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </FormField>
        <FormField label="Difficulty" htmlFor="difficulty">
          <select
            id="difficulty"
            value={plan.difficulty ?? ''}
            onChange={(e) => onPlanChange({ ...plan, difficulty: e.target.value })}
          >
            {DIFFICULTY_OPTIONS.map((option) => (
              <option key={option.value || 'unset'} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </FormField>
      </FormGrid>
      <FormGrid columns={2}>
        <FormField label="Estimated days" htmlFor="estimated_days">
          <input
            id="estimated_days"
            type="number"
            value={plan.estimated_days ?? ''}
            onChange={(e) => onPlanChange({ ...plan, estimated_days: parseNumber(e.target.value) })}
          />
        </FormField>
        <FormField label="Primary book" htmlFor="primary_book_key">
          <BookKeyCombobox
            id="primary_book_key"
            value={plan.primary_book_key ?? ''}
            onChange={(bookKey) => onPlanChange({ ...plan, primary_book_key: bookKey })}
            allowEmpty
          />
        </FormField>
      </FormGrid>
      <FormField label="Primary character" htmlFor="primary_character">
        <input
          id="primary_character"
          value={plan.primary_character ?? ''}
          onChange={(e) => onPlanChange({ ...plan, primary_character: e.target.value })}
        />
      </FormField>
      <FormField label="Tags" htmlFor="tags" hint="Comma-separated">
        <input id="tags" value={tagsString} onChange={(e) => onTagsChange(e.target.value)} />
      </FormField>
    </FormSection>
  );
}
