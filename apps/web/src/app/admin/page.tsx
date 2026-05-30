'use client';

import { useMemo } from 'react';
import Link from 'next/link';

import { useAdminOverview } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { PageHeader } from '@/components/admin/ui/PageHeader';

function StatCard({ label, value, hint }: { label: string; value: number | string; hint?: string }) {
  return (
    <div className="admin-stat-card">
      <p className="admin-stat-label">{label}</p>
      <p className="admin-stat-value">{value}</p>
      {hint ? <p className="admin-stat-hint">{hint}</p> : null}
    </div>
  );
}

function scheduleBadge(status: 'published' | 'draft' | 'gap') {
  if (status === 'published') return <Badge tone="success">Published</Badge>;
  if (status === 'draft') return <Badge tone="neutral">Draft</Badge>;
  return <Badge tone="warning">Gap</Badge>;
}

export default function AdminDashboardPage() {
  const { data, error, isLoading } = useAdminOverview();
  const overview = data?.overview ?? null;

  const emptyCategories = useMemo(
    () => overview?.categoryCoverage.filter((item) => item.publishedCount === 0) ?? [],
    [overview],
  );

  const gapDays = useMemo(
    () => overview?.todaySchedule.nextSevenDays.filter((day) => day.status === 'gap') ?? [],
    [overview],
  );

  return (
    <>
      <PageHeader
        title="Dashboard"
        description="Content operations overview — message cards, daily Home slots, and plan catalog."
        actions={
          <>
            <ButtonLink href="/admin/messages/new" variant="primary">
              New message card
            </ButtonLink>
            <ButtonLink href="/admin/today-messages/new" variant="secondary">
              Schedule today
            </ButtonLink>
          </>
        }
      />

      {error ? <Alert tone="error">{error.message}</Alert> : null}
      {isLoading && !overview ? <p className="admin-muted">Loading dashboard…</p> : null}

      {overview ? (
        <>
          <section className="admin-dashboard-section">
            <h2>Counts</h2>
            <div className="admin-dashboard-grid admin-dashboard-grid-stats">
              <StatCard
                label="Published message cards"
                value={overview.messageCounts.published}
                hint={`${overview.messageCounts.draft} draft · ${overview.messageCounts.archived} archived`}
              />
              <StatCard
                label="Today-eligible cards"
                value={overview.messageCounts.todayEligible}
                hint="Ready for Home scheduling"
              />
              <StatCard
                label="Active plans"
                value={overview.planCounts.active}
                hint={`${overview.planCounts.published} published`}
              />
              <StatCard
                label="Schedule gaps (7 days)"
                value={gapDays.length}
                hint={gapDays.length === 0 ? 'Next week covered' : 'Days without a slot'}
              />
            </div>
          </section>

          <section className="admin-dashboard-section">
            <div className="admin-dashboard-section-header">
              <h2>Today schedule</h2>
              <ButtonLink href="/admin/today-messages" variant="ghost">
                View all
              </ButtonLink>
            </div>
            <ul className="admin-schedule-list">
              {overview.todaySchedule.nextSevenDays.map((day) => (
                <li
                  key={day.date}
                  className={day.status === 'gap' ? 'admin-schedule-item admin-schedule-gap' : 'admin-schedule-item'}
                >
                  <span className="admin-schedule-date">{day.date}</span>
                  <span className="admin-schedule-detail">
                    {day.verseReference ? day.verseReference : 'No message scheduled'}
                  </span>
                  <span className="admin-schedule-status">{scheduleBadge(day.status)}</span>
                  {day.messageId ? (
                    <Link href={`/admin/today-messages/${day.messageId}`} className="admin-btn admin-btn-link">
                      Edit
                    </Link>
                  ) : (
                    <Link
                      href={`/admin/today-messages/new?publish_date=${day.date}`}
                      className="admin-btn admin-btn-link"
                    >
                      Schedule
                    </Link>
                  )}
                </li>
              ))}
            </ul>
          </section>

          <section className="admin-dashboard-section">
            <div className="admin-dashboard-section-header">
              <h2>Category coverage</h2>
              <ButtonLink href="/messages" variant="ghost">
                Public library
              </ButtonLink>
            </div>
            {emptyCategories.length > 0 ? (
              <Alert tone="warning">
                {emptyCategories.length} categor{emptyCategories.length === 1 ? 'y has' : 'ies have'} no published
                cards yet.
              </Alert>
            ) : (
              <Alert tone="success">All categories have at least one published card.</Alert>
            )}
            <div className="admin-coverage-grid">
              {overview.categoryCoverage.map((category) => (
                <div
                  key={category.key}
                  className={
                    category.publishedCount === 0
                      ? 'admin-coverage-item admin-coverage-item-empty'
                      : 'admin-coverage-item'
                  }
                >
                  <span className="admin-coverage-label">{category.label}</span>
                  <span className="admin-coverage-count">{category.publishedCount}</span>
                </div>
              ))}
            </div>
          </section>

          <section className="admin-dashboard-section">
            <h2>Quick actions</h2>
            <div className="admin-quick-actions">
              <ButtonLink href="/admin/messages/new" variant="secondary">
                New message card
              </ButtonLink>
              <ButtonLink href="/admin/today-messages/new" variant="secondary">
                Schedule today&apos;s message
              </ButtonLink>
              <ButtonLink href="/admin/plans" variant="secondary">
                Manage plans
              </ButtonLink>
              <ButtonLink href="/messages" variant="secondary">
                Open /messages
              </ButtonLink>
            </div>
          </section>
        </>
      ) : null}
    </>
  );
}
