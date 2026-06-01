'use client';

import { useMemo, useState } from 'react';
import { useSearchParams } from 'next/navigation';

import { TodayScheduleCalendar } from '@/components/admin/today-messages/TodayScheduleCalendar';
import { TodayScheduleList } from '@/components/admin/today-messages/TodayScheduleList';
import { useAdminMessages, useAdminTodayMessages } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import type { LinkedMessageSummary } from '@/lib/today-schedule-ui';
import { getUtcTodayIso, monthKeyFromDate } from '@/lib/today-schedule-ui';

function readInitialScheduleState(searchParams: ReturnType<typeof useSearchParams>) {
  const today = getUtcTodayIso();
  const dateParam = searchParams.get('date')?.trim();
  const monthParam = searchParams.get('month')?.trim();
  const selectedDate = dateParam && /^\d{4}-\d{2}-\d{2}$/.test(dateParam) ? dateParam : today;
  const monthKey =
    monthParam && /^\d{4}-\d{2}$/.test(monthParam) ? monthParam : monthKeyFromDate(selectedDate);

  return { monthKey, selectedDate };
}

export default function AdminTodayMessagesPageClient() {
  const searchParams = useSearchParams();
  const initialSchedule = useMemo(() => readInitialScheduleState(searchParams), [searchParams]);

  const {
    data: todayData,
    error: todayError,
    isLoading: todayLoading,
  } = useAdminTodayMessages();
  const { data: messageData } = useAdminMessages();

  const [language, setLanguage] = useState('en');
  const [monthKey, setMonthKey] = useState(initialSchedule.monthKey);
  const [selectedDate, setSelectedDate] = useState<string | null>(initialSchedule.selectedDate);

  const messages = todayData?.messages ?? [];
  const loading = todayLoading && messages.length === 0;

  const linkedByContentId = useMemo(() => {
    const map = new Map<string, LinkedMessageSummary>();
    for (const item of messageData?.messages ?? []) {
      map.set(item.id, {
        id: item.id,
        title: item.title,
        slug: item.slug,
        cover_image_url: item.cover_image_url,
        is_published: item.is_published,
      });
    }
    return map;
  }, [messageData?.messages]);

  return (
    <>
      <PageHeader
        label="Today's messages"
        title="Today's messages"
        description="Schedule one message card per day. The public Today page reads from the linked message card."
      />

      <div className="admin-filter-row">
        <label className="admin-filter-field" htmlFor="today_language_filter">
          <span className="admin-muted">Language</span>
          <select
            id="today_language_filter"
            value={language}
            onChange={(event) => setLanguage(event.target.value)}
          >
            <option value="en">English (en)</option>
            <option value="ko">Korean (ko)</option>
          </select>
        </label>
      </div>

      {todayError ? <Alert tone="error">{todayError.message}</Alert> : null}
      {loading ? <p className="admin-muted">Loading schedule…</p> : null}

      {!loading ? (
        <div className="admin-today-schedule-layout">
          <TodayScheduleCalendar
            monthKey={monthKey}
            language={language}
            messages={messages}
            linkedByContentId={linkedByContentId}
            selectedDate={selectedDate}
            onMonthChange={(nextMonthKey) => {
              setMonthKey(nextMonthKey);
              if (selectedDate && !selectedDate.startsWith(`${nextMonthKey}-`)) {
                setSelectedDate(null);
              }
            }}
            onSelectDate={(date) => {
              setSelectedDate(date);
              setMonthKey(monthKeyFromDate(date));
            }}
          />

          <TodayScheduleList
            monthKey={monthKey}
            language={language}
            messages={messages}
            linkedByContentId={linkedByContentId}
            selectedDate={selectedDate}
            onClearSelectedDate={() => setSelectedDate(null)}
          />
        </div>
      ) : null}
    </>
  );
}
