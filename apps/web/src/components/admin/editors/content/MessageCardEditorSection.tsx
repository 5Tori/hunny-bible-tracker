'use client';

import type { AdminContentInput } from '@/lib/content';
import {
  MESSAGE_BIBLE_CONTEXT_TAGS,
  MESSAGE_CATEGORIES,
  MESSAGE_SHARE_INTENTS,
  MESSAGE_THEME_TAGS,
  MESSAGE_TONES,
  getSituationsForCategory,
  type MessageEditorState,
} from '@/lib/message-admin';

interface MessageCardEditorSectionProps {
  content: AdminContentInput;
  messageState: MessageEditorState;
  onMessageStateChange: (next: MessageEditorState) => void;
}

function toggleValue(list: string[], value: string, checked: boolean) {
  if (checked) return list.includes(value) ? list : [...list, value];
  return list.filter((item) => item !== value);
}

export function MessageCardEditorSection({
  content,
  messageState,
  onMessageStateChange,
}: MessageCardEditorSectionProps) {
  const situations = messageState.primaryCategory
    ? getSituationsForCategory(messageState.primaryCategory)
    : [];

  const update = (patch: Partial<MessageEditorState>) => {
    onMessageStateChange({ ...messageState, ...patch });
  };

  return (
    <>
      <section className="admin-form-section">
        <h2>Message card content</h2>
        <div className="admin-field">
          <label htmlFor="short_reflection">Short reflection</label>
          <textarea
            id="short_reflection"
            value={messageState.shortReflection}
            onChange={(event) => update({ shortReflection: event.target.value })}
            rows={3}
            placeholder="A gentle, short reflection for the card."
          />
        </div>
        <div className="admin-field">
          <label htmlFor="prayer_text">Prayer text</label>
          <textarea
            id="prayer_text"
            value={messageState.prayerText}
            onChange={(event) => update({ prayerText: event.target.value })}
            rows={3}
            placeholder="Optional short prayer."
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
        <h2>Classification</h2>
        <div className="admin-field">
          <label htmlFor="primary_category">Primary category</label>
          <select
            id="primary_category"
            value={messageState.primaryCategory}
            onChange={(event) =>
              update({
                primaryCategory: event.target.value,
                situations: [],
              })
            }
          >
            <option value="">Select category</option>
            {MESSAGE_CATEGORIES.map((category) => (
              <option key={category.key} value={category.key}>
                {category.label}
              </option>
            ))}
          </select>
        </div>

        {situations.length > 0 ? (
          <div className="admin-field">
            <p className="admin-muted">Situations</p>
            <div className="content-plan-options">
              {situations.map((situation) => (
                <label key={situation.key} className="content-plan-option">
                  <input
                    type="checkbox"
                    checked={messageState.situations.includes(situation.key)}
                    onChange={(event) =>
                      update({
                        situations: toggleValue(
                          messageState.situations,
                          situation.key,
                          event.target.checked,
                        ),
                      })
                    }
                  />
                  <span>{situation.label}</span>
                </label>
              ))}
            </div>
          </div>
        ) : null}

        <TaxonomyCheckboxGroup
          title="Theme tags"
          options={MESSAGE_THEME_TAGS}
          selected={messageState.themeTags}
          onChange={(themeTags) => update({ themeTags })}
        />
        <TaxonomyCheckboxGroup
          title="Bible context"
          options={MESSAGE_BIBLE_CONTEXT_TAGS}
          selected={messageState.bibleContextTags}
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
          onChange={(shareIntents) => update({ shareIntents })}
        />

        <div className="admin-checkbox-row">
          <label htmlFor="is_today_eligible">Eligible for Today&apos;s Message</label>
          <input
            id="is_today_eligible"
            type="checkbox"
            checked={messageState.isTodayEligible}
            onChange={(event) => update({ isTodayEligible: event.target.checked })}
          />
        </div>
      </section>

      <section className="admin-form-section">
        <h2>Card preview</h2>
        <div className="message-card-preview">
          {content.cover_image_url ? (
            <img src={content.cover_image_url} alt="" className="admin-cover-preview" />
          ) : null}
          <p className="message-card-preview-title">{content.title || 'Message title'}</p>
          {content.primary_verse_reference ? (
            <p className="message-card-preview-verse">{content.primary_verse_reference}</p>
          ) : null}
          {content.verse_text ? (
            <blockquote className="message-card-preview-quote">{content.verse_text}</blockquote>
          ) : null}
          {messageState.shortReflection ? (
            <p className="message-card-preview-reflection">{messageState.shortReflection}</p>
          ) : null}
        </div>
      </section>
    </>
  );
}

function TaxonomyCheckboxGroup({
  title,
  options,
  selected,
  onChange,
}: {
  title: string;
  options: Array<{ key: string; label: string }>;
  selected: string[];
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
                onChange(toggleValue(selected, option.key, event.target.checked))
              }
            />
            <span>{option.label}</span>
          </label>
        ))}
      </div>
    </div>
  );
}
