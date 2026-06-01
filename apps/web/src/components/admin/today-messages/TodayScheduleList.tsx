'use client';

import Link from 'next/link';

import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { DataTable } from '@/components/admin/ui/DataTable';
import { EmptyState } from '@/components/admin/ui/EmptyState';
import type { LinkedMessageSummary } from '@/lib/today-schedule-ui';
import {
  findTodaySlotForDate,
  formatMonthLabel,
  listTodaySlotsForMonth,
  resolveTodaySlotStatus,
  todaySlotDisplayLabel,
} from '@/lib/today-schedule-ui';
import type { TodayMessageBase } from '@/lib/today-messages';

const COLUMNS = [
  { key: 'date', header: 'Date' },
  { key: 'message', header: 'Message card' },
  { key: 'status', header: 'Status' },
  { key: 'actions', header: 'Actions' },
];

interface TodayScheduleListProps {
  monthKey: string;
  language: string;
  messages: TodayMessageBase[];
  linkedByContentId: Map<string, LinkedMessageSummary>;
  selectedDate: string | null;
  onClearSelectedDate: () => void;
}

export function TodayScheduleList({
  monthKey,
  language,
  messages,
  linkedByContentId,
  selectedDate,
  onClearSelectedDate,
}: TodayScheduleListProps) {
  const monthRows = listTodaySlotsForMonth(messages, monthKey, language);
  const rows = selectedDate
    ? monthRows.filter((item) => item.publish_date === selectedDate)
    : monthRows;

  const selectedIsGap =
    selectedDate != null && !findTodaySlotForDate(messages, selectedDate, language);

  return (
    <section className="admin-today-list" aria-label="Today message schedule list">
      <div className="admin-today-list-header">
        <div>
          <h2>{selectedDate ? `Slots on ${selectedDate}` : `All slots in ${formatMonthLabel(monthKey)}`}</h2>
          <p className="admin-muted">
            Each day uses one Today-eligible message card. Verse, image, context, and hint come from
            that card.
          </p>
        </div>
        <div className="admin-today-list-actions">
          {selectedDate ? (
            <button type="button" className="admin-btn admin-btn-ghost" onClick={onClearSelectedDate}>
              Show full month
            </button>
          ) : null}
          <ButtonLink
            href={
              selectedDate
                ? `/admin/today-messages/new?publish_date=${selectedDate}&language=${language}`
                : `/admin/today-messages/new?language=${language}`
            }
            variant="secondary"
          >
            Schedule slot
          </ButtonLink>
        </div>
      </div>

      {selectedIsGap ? (
        <EmptyState
          title="No message scheduled for this day"
          description="Pick a Today-eligible message card to fill this date."
          action={
            <ButtonLink
              href={`/admin/today-messages/new?publish_date=${selectedDate}&language=${language}`}
              variant="primary"
            >
              Schedule {selectedDate}
            </ButtonLink>
          }
        />
      ) : null}

      {!selectedIsGap && rows.length === 0 ? (
        <EmptyState
          title="No slots in this view"
          description="Use the calendar to pick a day and schedule a message card."
          action={
            <ButtonLink href="/admin/today-messages/new" variant="secondary">
              Schedule first slot
            </ButtonLink>
          }
        />
      ) : null}

      {!selectedIsGap && rows.length > 0 ? (
        <DataTable
          tableClassName="admin-table-today"
          columns={COLUMNS}
          rows={rows}
          rowKey={(item) => item.id}
          renderCell={(slot, key) => {
            const linked = slot.content_id ? linkedByContentId.get(slot.content_id) ?? null : null;

            switch (key) {
              case 'date':
                return slot.publish_date;
              case 'message':
                if (!linked) {
                  return <span className="admin-muted">Missing message card</span>;
                }
                return (
                  <span className="admin-table-title-cell">
                    {linked.cover_image_url ? (
                      <img src={linked.cover_image_url} alt="" className="admin-table-thumb" />
                    ) : null}
                    <span>
                      <strong>{todaySlotDisplayLabel(slot, linked)}</strong>
                      <small className="admin-muted">{linked.slug}</small>
                    </span>
                  </span>
                );
              case 'status':
                return resolveTodaySlotStatus(slot, linked) === 'published' ? (
                  <Badge tone="success">Live</Badge>
                ) : (
                  <Badge tone="neutral">Draft card</Badge>
                );
              case 'actions':
                return (
                  <span className="admin-table-actions">
                    <Link href={`/admin/today-messages/${slot.id}`} className="admin-btn admin-btn-link">
                      Edit slot
                    </Link>
                    {linked ? (
                      <Link href={`/admin/messages/${linked.id}`} className="admin-btn admin-btn-link">
                        Edit card
                      </Link>
                    ) : null}
                    {resolveTodaySlotStatus(slot, linked) === 'published' ? (
                      <Link
                        href={`/today-message/${slot.publish_date}`}
                        className="admin-btn admin-btn-link"
                        target="_blank"
                      >
                        View
                      </Link>
                    ) : null}
                  </span>
                );
              default:
                return null;
            }
          }}
        />
      ) : null}
    </section>
  );
}
