import { BookChapterRangeSelects } from '@/components/admin/BookChapterRangeSelects';
import { BookKeyCombobox } from '@/components/admin/BookKeyCombobox';
import { Button } from '@/components/admin/ui/Button';
import { FormField } from '@/components/admin/ui/FormField';
import { FormSection } from '@/components/admin/ui/FormSection';
import { clampPlanItemChapters } from '@/lib/bible-books';
import type { AdminPlanInput } from '@/lib/plans';

type PlanSectionsEditorProps = {
  plan: AdminPlanInput;
  updateSection: (index: number, update: Partial<AdminPlanInput['sections'][number]>) => void;
  updateSectionItem: (
    sectionIndex: number,
    itemIndex: number,
    update: Partial<AdminPlanInput['sections'][number]['items'][number]>,
  ) => void;
  addSection: () => void;
  removeSection: (index: number) => void;
  addItem: (sectionIndex: number) => void;
  removeItem: (sectionIndex: number, itemIndex: number) => void;
};

export function PlanSectionsEditor({
  plan,
  updateSection,
  updateSectionItem,
  addSection,
  removeSection,
  addItem,
  removeItem,
}: PlanSectionsEditorProps) {
  return (
    <FormSection title="Sections">
      {plan.sections.map((section, sectionIndex) => (
        <div key={section.section_key || sectionIndex} className="admin-section-card">
          <div className="admin-section-header">
            <h3>Section {sectionIndex + 1}</h3>
            <Button variant="link" onClick={() => removeSection(sectionIndex)}>
              Remove section
            </Button>
          </div>
          <FormField label="Section title">
            <input
              value={section.title}
              onChange={(e) => updateSection(sectionIndex, { title: e.target.value })}
            />
          </FormField>
          <FormField label="Section description">
            <textarea
              rows={2}
              value={section.description ?? ''}
              onChange={(e) => updateSection(sectionIndex, { description: e.target.value })}
            />
          </FormField>
          <div className="admin-items-grid">
            {section.items.map((item, itemIndex) => (
              <div key={`${section.section_key}-${itemIndex}`} className="admin-item-card">
                <div className="admin-section-header">
                  <h4>Item {itemIndex + 1}</h4>
                  <Button variant="link" onClick={() => removeItem(sectionIndex, itemIndex)}>
                    Remove item
                  </Button>
                </div>
                <FormField label="Book key" htmlFor={`book_key-${sectionIndex}-${itemIndex}`}>
                  <BookKeyCombobox
                    id={`book_key-${sectionIndex}-${itemIndex}`}
                    value={item.book_key}
                    onChange={(bookKey) => {
                      const clamped = clampPlanItemChapters({
                        book_key: bookKey,
                        start_chapter: item.start_chapter,
                        end_chapter: item.end_chapter,
                      });
                      updateSectionItem(sectionIndex, itemIndex, {
                        book_key: bookKey,
                        start_chapter: clamped.start_chapter,
                        end_chapter: clamped.end_chapter,
                      });
                    }}
                  />
                </FormField>
                <BookChapterRangeSelects
                  bookKey={item.book_key}
                  startChapter={item.start_chapter}
                  endChapter={item.end_chapter}
                  startId={`start-chapter-${sectionIndex}-${itemIndex}`}
                  endId={`end-chapter-${sectionIndex}-${itemIndex}`}
                  onChange={(next) => updateSectionItem(sectionIndex, itemIndex, next)}
                />
              </div>
            ))}
          </div>
          <Button variant="secondary" onClick={() => addItem(sectionIndex)}>
            Add item
          </Button>
        </div>
      ))}
      <Button variant="secondary" onClick={addSection}>
        Add section
      </Button>
    </FormSection>
  );
}
