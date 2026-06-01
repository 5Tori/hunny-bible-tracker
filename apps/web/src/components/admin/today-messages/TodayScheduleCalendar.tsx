'use client';

import Link from 'next/link';

import { Badge } from '@/components/admin/ui/Badge';
import { Button } from '@/components/admin/ui/Button';
import type { LinkedMessageSummary } from '@/lib/today-schedule-ui';
import {
  buildCalendarMonth,
  CALENDAR_WEEKDAY_LABELS,
  formatMonthLabel,
  getUtcTodayIso,
  shiftMonthKey,
  todaySlotDisplayLabel,
  type TodayScheduleDay,
} from '@/lib/today-schedule-ui';
import type { TodayMessageBase } from '@/lib/today-messages';

interface TodayScheduleCalendarProps {
  monthKey: string;
  language: string;
  messages: TodayMessageBase[];
  linkedByContentId: Map<string, LinkedMessageSummary>;
  selectedDate: string | null;
  onMonthChange: (monthKey: string) => void;
  onSelectDate: (date: string) => void;
}

function dayButtonClass(day: TodayScheduleDay, selectedDate: string | null, today: string) {
  const classes = ['admin-today-calendar-day'];
  if (!day.inMonth) classes.push('is-outside');
  if (day.date === selectedDate) classes.push('is-selected');
  if (day.date === today) classes.push('is-today');
  if (day.status === 'published') classes.push('is-published');
  if (day.status === 'draft') classes.push('is-draft');
  if (day.status === 'gap' && day.inMonth) classes.push('is-gap');
  return classes.join(' ');
}

export function TodayScheduleCalendar({
  monthKey,
  language,
  messages,
  linkedByContentId,
  selectedDate,
  onMonthChange,
  onSelectDate,
}: TodayScheduleCalendarProps) {
  const today = getUtcTodayIso();
  const days = buildCalendarMonth(monthKey, messages, language, linkedByContentId);

  return (
    <section className="admin-today-calendar" aria-label="Today message schedule calendar">
      <div className="admin-today-calendar-header">
        <div>
          <h2>{formatMonthLabel(monthKey)}</h2>
          <p className="admin-muted">Click a day to filter the list. Empty days can be scheduled in advance.</p>
        </div>
        <div className="admin-today-calendar-nav">
          <Button variant="ghost" onClick={() => onMonthChange(shiftMonthKey(monthKey, -1))}>
            Previous
          </Button>
          <Button variant="ghost" onClick={() => onMonthChange(monthKeyFromToday())}>
            Today
          </Button>
          <Button variant="ghost" onClick={() => onMonthChange(shiftMonthKey(monthKey, 1))}>
            Next
          </Button>
        </div>
      </div>

      <div className="admin-today-calendar-legend">
        <span className="admin-today-calendar-legend-item">
          <span className="admin-today-calendar-dot is-published" /> Published
        </span>
        <span className="admin-today-calendar-legend-item">
          <span className="admin-today-calendar-dot is-draft" /> Draft
        </span>
        <span className="admin-today-calendar-legend-item">
          <span className="admin-today-calendar-dot is-gap" /> Open
        </span>
      </div>

      <div className="admin-today-calendar-weekdays">
        {CALENDAR_WEEKDAY_LABELS.map((label) => (
          <span key={label} className="admin-today-calendar-weekday">
            {label}
          </span>
        ))}
      </div>

      <div className="admin-today-calendar-grid">
        {days.map((day) => {
          const linked = day.slot?.content_id
            ? linkedByContentId.get(day.slot.content_id) ?? null
            : null;
          const label = day.slot
            ? todaySlotDisplayLabel(day.slot, linked)
            : day.inMonth
              ? 'Open'
              : '';

          return (
            <button
              key={day.date}
              type="button"
              className={dayButtonClass(day, selectedDate, today)}
              onClick={() => {
                if (day.inMonth) onSelectDate(day.date);
              }}
              disabled={!day.inMonth}
            >
              <span className="admin-today-calendar-day-number">
                {Number(day.date.slice(8, 10))}
              </span>
              {day.inMonth && day.status !== 'gap' ? (
                <span className="admin-today-calendar-day-label">{label}</span>
              ) : null}
              {day.inMonth ? (
                <span className="admin-today-calendar-day-status">
                  {day.status === 'published' ? (
                    <Badge tone="success">Live</Badge>
                  ) : day.status === 'draft' ? (
                    <Badge tone="neutral">Draft</Badge>
                  ) : (
                    <span className="admin-muted">—</span>
                  )}
                </span>
              ) : null}
            </button>
          );
        })}
      </div>

      {selectedDate ? (
        <div className="admin-today-calendar-selection">
          <p className="admin-muted">
            Selected: <strong>{selectedDate}</strong>
          </p>
          {findSlot(days, selectedDate)?.slot ? (
            <Link
              href={`/admin/today-messages/${findSlot(days, selectedDate)!.slot!.id}`}
              className="admin-btn admin-btn-link"
            >
              Edit slot
            </Link>
          ) : (
            <Link
              href={`/admin/today-messages/new?publish_date=${selectedDate}&language=${language}`}
              className="admin-btn admin-btn-link"
            >
              Schedule message
            </Link>
          )}
        </div>
      ) : null}
    </section>
  );
}

function findSlot(days: TodayScheduleDay[], date: string) {
  return days.find((day) => day.date === date && day.inMonth) ?? null;
}

function monthKeyFromToday() {
  return getUtcTodayIso().slice(0, 7);
}
