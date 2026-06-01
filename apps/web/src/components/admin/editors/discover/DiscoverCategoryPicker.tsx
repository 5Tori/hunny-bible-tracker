'use client';

import { FormSection } from '@/components/admin/ui/FormSection';
import { DISCOVER_CATEGORY_OPTIONS } from '@/lib/discover-content';
import type { DiscoverContentType } from '@/lib/discover-content';

type DiscoverCategoryPickerProps = {
  value: string;
  onChange: (category: DiscoverContentType) => void;
};

export function DiscoverCategoryPicker({ value, onChange }: DiscoverCategoryPickerProps) {
  return (
    <FormSection title="Category">
      <p className="admin-muted">
        Choose Video, Article, or Cartoon. You can still mix a video link, content blocks, and
        slides in the same post when it helps the story.
      </p>
      <div className="admin-discover-format-grid">
        {DISCOVER_CATEGORY_OPTIONS.map((option) => {
          const selected = value === option.value;
          return (
            <label
              key={option.value}
              className={
                selected
                  ? 'admin-discover-format-card admin-discover-format-card-selected'
                  : 'admin-discover-format-card'
              }
            >
              <input
                type="radio"
                name="discover_category"
                value={option.value}
                checked={selected}
                onChange={() => onChange(option.value)}
              />
              <span className="admin-discover-format-label">{option.label}</span>
              <span className="admin-muted">{option.description}</span>
            </label>
          );
        })}
      </div>
    </FormSection>
  );
}
