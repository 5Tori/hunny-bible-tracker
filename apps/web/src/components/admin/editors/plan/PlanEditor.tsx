'use client';

import { useRouter } from 'next/navigation';

import { Alert } from '@/components/admin/ui/Alert';
import { Button, ButtonLink } from '@/components/admin/ui/Button';
import { PageHeader } from '@/components/admin/ui/PageHeader';

import { PlanBasicsSection } from './PlanBasicsSection';
import { PlanCatalogSection } from './PlanCatalogSection';
import { PlanSectionsEditor } from './PlanSectionsEditor';
import { usePlanEditor } from './use-plan-editor';

export default function PlanEditor({ planId }: { planId?: string }) {
  const router = useRouter();
  const editor = usePlanEditor(planId);

  if (editor.loading) {
    return <p className="admin-muted">Loading plan…</p>;
  }

  return (
    <>
      <PageHeader
        title={planId ? 'Edit plan' : 'New plan'}
        description="Manage plan content, sections, chapters, tags, and publish state."
        actions={<ButtonLink href="/admin/plans" variant="secondary">Back to list</ButtonLink>}
      />

      {editor.error ? <Alert tone="error">{editor.error}</Alert> : null}
      {editor.success ? <Alert tone="success">{editor.success}</Alert> : null}

      <div className="admin-editor-layout">
        <div className="admin-editor-main">
          <PlanBasicsSection
            plan={editor.plan}
            tagsString={editor.tagsString}
            uploading={editor.uploading}
            onPlanChange={editor.setPlan}
            onTagsChange={editor.setTagsString}
            onUpload={(file) => void editor.handleUpload(file)}
          />
          <PlanSectionsEditor
            plan={editor.plan}
            updateSection={editor.updateSection}
            updateSectionItem={editor.updateSectionItem}
            addSection={editor.addSection}
            removeSection={editor.removeSection}
            addItem={editor.addItem}
            removeItem={editor.removeItem}
          />
        </div>
        <aside className="admin-editor-aside">
          <PlanCatalogSection plan={editor.plan} onPlanChange={editor.setPlan} />
          <div className="admin-sticky-actions">
            <p className="admin-muted">Total chapters: {editor.calculatedTotalChapters}</p>
            <Button variant="primary" loading={editor.saving} onClick={() => void editor.submit()}>
              {planId ? 'Save changes' : 'Create plan'}
            </Button>
            <Button variant="ghost" onClick={() => router.push('/admin/plans')}>
              Cancel
            </Button>
          </div>
        </aside>
      </div>
    </>
  );
}
