'use client';

import { useMemo } from 'react';

import { FormField } from '@/components/admin/ui/FormField';
import { FormSection } from '@/components/admin/ui/FormSection';
import { formatCatalogReadingDuration, formatPlanChapters } from '@/lib/plan-display';
import { calculatePlanEstimatedMinutes } from '@/lib/plan-estimates';
import type { AdminPlanInput } from '@/lib/plans';

import { parseNumber } from './plan-editor-utils';

type PlanEditorReadingStatsProps = {
  sections: AdminPlanInput['sections'];
  totalChapters: number;
  estimatedTotalMinutes: number | null;
  onEstimatedTotalChange: (minutes: number | null) => void;
};

function minutesToHoursInputValue(totalMinutes: number): string {
  const hours = totalMinutes / 60;
  if (hours % 1 === 0) return String(hours);
  return (Math.round(hours * 2) / 2).toFixed(1);
}

export function PlanEditorReadingStats({
  sections,
  totalChapters,
  estimatedTotalMinutes,
  onEstimatedTotalChange,
}: PlanEditorReadingStatsProps) {
  const autoMinutesPerChapter = useMemo(() => calculatePlanEstimatedMinutes(sections), [sections]);
  const autoTotalMinutes = useMemo(() => {
    if (!autoMinutesPerChapter || totalChapters <= 0) return null;
    return autoMinutesPerChapter * totalChapters;
  }, [autoMinutesPerChapter, totalChapters]);

  const hasOverride = estimatedTotalMinutes != null && estimatedTotalMinutes > 0;
  const previewMinutes = hasOverride ? estimatedTotalMinutes : autoTotalMinutes;
  const chaptersLabel = formatPlanChapters(totalChapters);

  return (
    <FormSection title="Reading estimates">
      <p className="admin-muted">
        Catalog shows total time in 0.5 hr steps. Leave blank to auto-calculate from sections on save
        (7 sec/verse). Enter total hours to override.
      </p>

      <FormField
        label="Total reading time (hours)"
        htmlFor="estimated_total_hours"
        hint={
          hasOverride
            ? previewMinutes != null
              ? `Catalog label: ${formatCatalogReadingDuration(previewMinutes)}`
              : undefined
            : autoTotalMinutes != null
              ? `On save: auto → ${formatCatalogReadingDuration(autoTotalMinutes)}`
              : 'Add valid chapter ranges to enable auto.'
        }
      >
        <div className="admin-reading-estimate-field">
          <input
            id="estimated_total_hours"
            type="number"
            min={0.5}
            step={0.5}
            placeholder={
              autoTotalMinutes != null ? minutesToHoursInputValue(autoTotalMinutes) : 'Auto'
            }
            value={hasOverride ? minutesToHoursInputValue(estimatedTotalMinutes) : ''}
            onChange={(event) => {
              const raw = event.target.value.trim();
              if (raw === '') {
                onEstimatedTotalChange(null);
                return;
              }
              const hours = parseNumber(raw);
              if (hours != null && hours > 0) {
                onEstimatedTotalChange(Math.round(hours * 60));
              } else {
                onEstimatedTotalChange(null);
              }
            }}
          />
          <span className="admin-muted">hrs</span>
          {hasOverride ? (
            <button
              type="button"
              className="admin-btn admin-btn-link"
              onClick={() => onEstimatedTotalChange(null)}
            >
              Use auto
            </button>
          ) : null}
        </div>
      </FormField>

      <dl className="admin-reading-stats">
        <div>
          <dt>Chapters</dt>
          <dd>{chaptersLabel ?? '—'}</dd>
        </div>
        <div>
          <dt>Catalog display</dt>
          <dd>
            {previewMinutes != null ? formatCatalogReadingDuration(previewMinutes) : '—'}
          </dd>
        </div>
        {hasOverride && autoTotalMinutes != null && autoTotalMinutes !== estimatedTotalMinutes ? (
          <div>
            <dt>Auto from sections</dt>
            <dd className="admin-muted">{formatCatalogReadingDuration(autoTotalMinutes)}</dd>
          </div>
        ) : null}
        {!hasOverride && autoMinutesPerChapter != null ? (
          <div>
            <dt>Stored on save (avg)</dt>
            <dd className="admin-muted">{`${autoMinutesPerChapter} min/chapter`}</dd>
          </div>
        ) : null}
      </dl>
    </FormSection>
  );
}
