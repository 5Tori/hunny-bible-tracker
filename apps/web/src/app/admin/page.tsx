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
        label="Content operations"
        title="Dashboard"
        description="Message Card Library (/messages), Today’s Message schedule, and reading plans (/plans)."
        actions={
          <>
            <ButtonLink href="/admin/messages/new" variant="primary">
              New message card
            </ButtonLink>
            <ButtonLink href="/admin/plans/new" variant="secondary">
              New plan
            </ButtonLink>
          </>
        }
      />

      {error ? <Alert tone="error">{error.message}</Alert> : null}
      {isLoading && !overview ? <p className="admin-muted">Loading dashboard…</p> : null}

      {overview ? (
        <>
          <section className="admin-dashboard-section">
            <h2>At a glance</h2>
            <div className="admin-dashboard-grid admin-dashboard-grid-stats">
              <StatCard
                label="Published message cards"
                value={overview.messageCounts.published}
                hint={`${overview.messageCounts.draft} draft · ${overview.messageCounts.archived} archived`}
              />
              <StatCard
                label="Plans on /plans"
                value={overview.planCounts.browseVisible}
                hint={`${overview.planCounts.published} published · ${overview.planCounts.draft} draft`}
              />
              <StatCard
                label="Plan templates (active)"
                value={overview.planCounts.active}
                hint={`${overview.planCounts.total} total · ${overview.planCounts.archived} archived`}
              />
              <StatCard
                label="Today schedule gaps"
                value={gapDays.length}
                hint={gapDays.length === 0 ? 'Next 7 days covered' : 'Days without a Home slot'}
              />
            </div>
          </section>

          <section className="admin-dashboard-section">
            <div className="admin-dashboard-section-header">
              <div>
                <h2>Today schedule</h2>
                <p className="admin-muted admin-dashboard-section-lead">
                  Home daily message slots — link a published message card per day.
                </p>
              </div>
              <ButtonLink href="/admin/today-messages" variant="ghost">
                Open calendar
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
              <div>
                <h2>Message categories</h2>
                <p className="admin-muted admin-dashboard-section-lead">
                  Published cards per primary category (metadata or category tag).
                </p>
              </div>
              <ButtonLink href="/messages" variant="ghost">
                Public library
              </ButtonLink>
            </div>
            {emptyCategories.length > 0 ? (
              <Alert tone="warning">
                {emptyCategories.length} categor{emptyCategories.length === 1 ? 'y has' : 'ies have'} no published
                cards yet: {emptyCategories.map((item) => item.label).join(', ')}.
              </Alert>
            ) : (
              <Alert tone="success">All primary categories have at least one published card.</Alert>
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
              <ButtonLink href="/admin/today-messages" variant="secondary">
                Today schedule
              </ButtonLink>
              <ButtonLink href="/admin/plans" variant="secondary">
                Manage plans
              </ButtonLink>
              <ButtonLink href="/admin/plans/new" variant="secondary">
                New plan
              </ButtonLink>
              <ButtonLink href="/admin/discover" variant="secondary">
                Discover content
              </ButtonLink>
              <ButtonLink href="/messages" variant="secondary">
                Open /messages
              </ButtonLink>
              <ButtonLink href="/plans" variant="secondary">
                Open /plans
              </ButtonLink>
            </div>
          </section>
        </>
      ) : null}
    </>
  );
}
