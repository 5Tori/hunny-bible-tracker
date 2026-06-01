'use client';

import {
  MESSAGE_BIBLE_CONTEXTS,
  MESSAGE_PRIMARY_CATEGORIES,
  MESSAGE_SHARE_INTENTS,
  MESSAGE_TAXONOMY_LIMITS,
  MESSAGE_THEMES,
  MESSAGE_TONES,
  getAllSituations,
  getSuggestedSituationsForCategory,
  type MessageEditorState,
} from '@/lib/message-admin';

interface MessageCardEditorSectionProps {
  messageState: MessageEditorState;
  onMessageStateChange: (next: MessageEditorState) => void;
}

function toggleValue(list: string[], value: string, checked: boolean, max?: number) {
  if (checked) {
    if (list.includes(value)) return list;
    if (max != null && list.length >= max) return list;
    return [...list, value];
  }
  return list.filter((item) => item !== value);
}

function sortSituationsForEditor(primaryCategory: string) {
  const all = getAllSituations();
  if (!primaryCategory) return all;

  const suggestedKeys = new Set(
    getSuggestedSituationsForCategory(primaryCategory).map((entry) => entry.key),
  );

  return [...all].sort((a, b) => {
    const aSuggested = suggestedKeys.has(a.key) ? 0 : 1;
    const bSuggested = suggestedKeys.has(b.key) ? 0 : 1;
    if (aSuggested !== bSuggested) return aSuggested - bSuggested;
    return (a.sortOrder ?? 0) - (b.sortOrder ?? 0);
  });
}

export function MessageCardEditorSection({
  messageState,
  onMessageStateChange,
}: MessageCardEditorSectionProps) {
  const situations = sortSituationsForEditor(messageState.primaryCategory);
  const suggestedSituationKeys = new Set(
    messageState.primaryCategory
      ? getSuggestedSituationsForCategory(messageState.primaryCategory).map((entry) => entry.key)
      : [],
  );

  const update = (patch: Partial<MessageEditorState>) => {
    onMessageStateChange({ ...messageState, ...patch });
  };

  const onPrimaryCategoryChange = (primaryCategory: string) => {
    onMessageStateChange({
      ...messageState,
      primaryCategory,
    });
  };

  return (
    <>
      <section className="admin-form-section">
        <h2>Card copy</h2>
        <p className="admin-muted">
          Short reflection and optional prayer — shown on the public message detail page, not on the
          card image overlay.
        </p>
        <div className="admin-field">
          <label htmlFor="message_context">Short reflection</label>
          <textarea
            id="message_context"
            value={messageState.context}
            onChange={(event) => update({ context: event.target.value })}
            rows={3}
            placeholder="A gentle line that helps the verse land."
          />
        </div>
        <div className="admin-field">
          <label htmlFor="message_hint">Prayer / hint</label>
          <textarea
            id="message_hint"
            value={messageState.hint}
            onChange={(event) => update({ hint: event.target.value })}
            rows={3}
            placeholder="Optional one-line prayer or prompt."
          />
        </div>
        <div className="admin-field admin-form-grid-2">
          <div>
            <label htmlFor="card_template_key">Card template</label>
            <input
              id="card_template_key"
              value={messageState.cardTemplateKey}
              onChange={(event) => update({ cardTemplateKey: event.target.value })}
              placeholder="classic"
            />
          </div>
          <div>
            <label htmlFor="search_aliases">Search aliases</label>
            <input
              id="search_aliases"
              value={messageState.searchAliasesText}
              onChange={(event) => update({ searchAliasesText: event.target.value })}
              placeholder="future, tomorrow, worried"
            />
          </div>
        </div>
      </section>

      <section className="admin-form-section">
        <h2>Public classification</h2>
        <p className="admin-muted">
          Matches <code>/messages</code> filters: one primary category, up to{' '}
          {MESSAGE_TAXONOMY_LIMITS.situations} situations, up to {MESSAGE_TAXONOMY_LIMITS.themes}{' '}
          themes. Required to publish.
        </p>
        <div className="admin-field">
          <label htmlFor="primary_category">Primary category</label>
          <select
            id="primary_category"
            value={messageState.primaryCategory}
            onChange={(event) => onPrimaryCategoryChange(event.target.value)}
          >
            <option value="">Select category</option>
            {MESSAGE_PRIMARY_CATEGORIES.map((category) => (
              <option key={category.key} value={category.key}>
                {category.label}
              </option>
            ))}
          </select>
        </div>

        <div className="admin-field">
          <p className="admin-muted">
            Situations {messageState.primaryCategory ? '(suggested for this category first)' : ''}
          </p>
          <div className="content-plan-options">
            {situations.map((situation) => {
              const isSuggested = suggestedSituationKeys.has(situation.key);
              return (
                <label
                  key={situation.key}
                  className={`content-plan-option${isSuggested ? ' content-plan-option-suggested' : ''}`}
                >
                  <input
                    type="checkbox"
                    checked={messageState.situations.includes(situation.key)}
                    onChange={(event) =>
                      update({
                        situations: toggleValue(
                          messageState.situations,
                          situation.key,
                          event.target.checked,
                          MESSAGE_TAXONOMY_LIMITS.situations,
                        ),
                      })
                    }
                  />
                  <span>
                    {situation.label}
                    {isSuggested ? (
                      <span className="admin-taxonomy-suggested-mark">Suggested</span>
                    ) : null}
                  </span>
                </label>
              );
            })}
          </div>
        </div>

        <TaxonomyCheckboxGroup
          title="Themes"
          options={MESSAGE_THEMES}
          selected={messageState.themeTags}
          maxSelected={MESSAGE_TAXONOMY_LIMITS.themes}
          onChange={(themeTags) => update({ themeTags })}
        />
      </section>

      <section className="admin-form-section">
        <h2>Internal metadata</h2>
        <p className="admin-muted">
          Curation and share presets — not shown as primary chips on the public message page.
        </p>
        <TaxonomyCheckboxGroup
          title="Bible context"
          options={MESSAGE_BIBLE_CONTEXTS}
          selected={messageState.bibleContextTags}
          maxSelected={MESSAGE_TAXONOMY_LIMITS.bibleContexts}
          onChange={(bibleContextTags) => update({ bibleContextTags })}
        />

        <div className="admin-field">
          <label htmlFor="tone">Tone</label>
          <select
            id="tone"
            value={messageState.tone}
            onChange={(event) => update({ tone: event.target.value })}
          >
            <option value="">Select tone</option>
            {MESSAGE_TONES.map((tone) => (
              <option key={tone.key} value={tone.key}>
                {tone.label}
              </option>
            ))}
          </select>
        </div>

        <TaxonomyCheckboxGroup
          title="Share intent"
          options={MESSAGE_SHARE_INTENTS}
          selected={messageState.shareIntents}
          maxSelected={MESSAGE_TAXONOMY_LIMITS.shareIntents}
          onChange={(shareIntents) => update({ shareIntents })}
        />
      </section>
    </>
  );
}

function TaxonomyCheckboxGroup({
  title,
  options,
  selected,
  maxSelected,
  onChange,
}: {
  title: string;
  options: Array<{ key: string; label: string }>;
  selected: string[];
  maxSelected?: number;
  onChange: (next: string[]) => void;
}) {
  return (
    <div className="admin-field">
      <p className="admin-muted">{title}</p>
      <div className="content-plan-options">
        {options.map((option) => (
          <label key={option.key} className="content-plan-option">
            <input
              type="checkbox"
              checked={selected.includes(option.key)}
              onChange={(event) =>
                onChange(toggleValue(selected, option.key, event.target.checked, maxSelected))
              }
            />
            <span>{option.label}</span>
          </label>
        ))}
      </div>
    </div>
  );
}
