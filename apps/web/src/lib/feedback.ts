import { sql } from '@/lib/db/neon';

const feedbackCategories = new Set(['bug', 'idea', 'other']);

export class FeedbackValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'FeedbackValidationError';
  }
}

export interface FeedbackInput {
  category?: unknown;
  message?: unknown;
  contactEmail?: unknown;
  signedInEmail?: unknown;
  source?: unknown;
  appVersion?: unknown;
  platform?: unknown;
  metadata?: unknown;
}

export async function createFeedbackMessage(rawInput: FeedbackInput) {
  const input = normalizeFeedbackInput(rawInput);
  const rows = (await sql`
    insert into feedback_messages (
      category,
      message,
      contact_email,
      signed_in_email,
      source,
      app_version,
      platform,
      metadata,
      created_at
    ) values (
      ${input.category},
      ${input.message},
      ${input.contactEmail},
      ${input.signedInEmail},
      ${input.source},
      ${input.appVersion},
      ${input.platform},
      ${JSON.stringify(input.metadata)}::jsonb,
      now()
    )
    returning id::text, category, created_at
  `) as Array<{ id: string; category: string; created_at: string }>;

  return rows[0] ?? null;
}

function normalizeFeedbackInput(input: FeedbackInput) {
  const category = stringOrNull(input.category)?.toLowerCase() ?? 'other';
  if (!feedbackCategories.has(category)) {
    throw new FeedbackValidationError('Invalid feedback category.');
  }

  const message = stringOrNull(input.message);
  if (!message) {
    throw new FeedbackValidationError('Feedback message is required.');
  }
  if (message.length > 1000) {
    throw new FeedbackValidationError('Feedback message is too long.');
  }

  return {
    category,
    message,
    contactEmail: stringOrNull(input.contactEmail),
    signedInEmail: stringOrNull(input.signedInEmail),
    source: stringOrNull(input.source) ?? 'mobile_settings',
    appVersion: stringOrNull(input.appVersion),
    platform: stringOrNull(input.platform),
    metadata: recordOrEmpty(input.metadata),
  };
}

function stringOrNull(value: unknown) {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed.slice(0, 1000);
}

function recordOrEmpty(value: unknown) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return {};
  return value as Record<string, unknown>;
}
