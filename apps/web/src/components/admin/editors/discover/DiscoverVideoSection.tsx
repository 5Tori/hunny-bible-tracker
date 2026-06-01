'use client';

import { FormField } from '@/components/admin/ui/FormField';
import { FormSection } from '@/components/admin/ui/FormSection';
import type { AdminContentInput } from '@/lib/content';

import { parseDiscoverNumber } from './discover-editor-utils';

type DiscoverVideoSectionProps = {
  content: AdminContentInput;
  emphasized: boolean;
  onChange: (next: AdminContentInput) => void;
};

export function DiscoverVideoSection({ content, emphasized, onChange }: DiscoverVideoSectionProps) {
  return (
    <FormSection title="Video">
      <p className="admin-muted">
        {emphasized
          ? 'Video category — add a YouTube link (or external URL). Post content blocks go below.'
          : 'Optional — include a video even when the category is Article or Cartoon.'}
      </p>
      <FormField label="YouTube or video URL" htmlFor="discover_external_url">
        <input
          id="discover_external_url"
          value={content.external_url ?? ''}
          onChange={(event) => onChange({ ...content, external_url: event.target.value })}
          placeholder="https://www.youtube.com/watch?v=…"
        />
      </FormField>
      <FormField label="Duration (seconds)" htmlFor="discover_duration">
        <input
          id="discover_duration"
          type="number"
          min={0}
          value={content.duration_seconds ?? ''}
          onChange={(event) =>
            onChange({ ...content, duration_seconds: parseDiscoverNumber(event.target.value) })
          }
        />
      </FormField>
    </FormSection>
  );
}
