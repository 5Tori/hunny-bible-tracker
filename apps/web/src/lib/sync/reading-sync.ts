import crypto from 'crypto';

import { getSupabaseAdmin } from '@/lib/supabase/admin';

type JsonRecord = Record<string, unknown>;

export type ReadingSyncPushResult = {
  serverTime: string;
  backupVersion: number;
  payloadHash: string;
  updatedAt: string;
  counts: {
    plans: number;
    progress: number;
    activities: number;
    completionEvents: number;
  };
};

export type ReadingSyncBootstrapResult = {
  serverTime: string;
  backupVersion: number | null;
  payloadHash: string | null;
  updatedAt: string | null;
  payload: JsonRecord | null;
};

class SyncInputError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'SyncInputError';
  }
}

export function isSyncInputError(error: unknown): error is SyncInputError {
  return error instanceof SyncInputError;
}

export async function pushReadingSync(
  authUserId: string,
  body: unknown,
): Promise<ReadingSyncPushResult> {
  const snapshot = parseReadingBackupSnapshot(body);
  const canonicalPayload = canonicalJson(snapshot);
  const byteLength = Buffer.byteLength(canonicalPayload, 'utf8');
  if (byteLength > maxBackupPayloadBytes) {
    throw new SyncInputError('backup_payload_too_large');
  }

  const payloadHash = crypto
    .createHash('sha256')
    .update(canonicalPayload)
    .digest('hex');

  const payloadObject = JSON.parse(canonicalPayload) as JsonRecord;
  const { data: saved, error } = await getSupabaseAdmin()
    .from('user_reading_backups')
    .upsert(
      {
        auth_user_id: authUserId,
        backup_version: snapshot.v,
        payload_jsonb: payloadObject,
        payload_hash: payloadHash,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'auth_user_id' },
    )
    .select('backup_version, payload_hash, updated_at')
    .single();

  if (error) {
    console.error('reading sync push store failed', error);
    throw error;
  }
  if (!saved) throw new SyncInputError('backup_write_failed');

  return {
    serverTime: new Date().toISOString(),
    backupVersion: saved.backup_version,
    payloadHash: saved.payload_hash,
    updatedAt: toIsoString(saved.updated_at) ?? new Date().toISOString(),
    counts: countBackupSnapshot(snapshot),
  };
}

export async function getReadingSyncBootstrap(
  authUserId: string,
): Promise<ReadingSyncBootstrapResult> {
  const { data: backup, error } = await getSupabaseAdmin()
    .from('user_reading_backups')
    .select('backup_version, payload_hash, payload_jsonb, updated_at')
    .eq('auth_user_id', authUserId)
    .maybeSingle();

  if (error) {
    console.error('reading sync bootstrap store failed', error);
    throw error;
  }
  if (!backup) {
    return {
      serverTime: new Date().toISOString(),
      backupVersion: null,
      payloadHash: null,
      updatedAt: null,
      payload: null,
    };
  }

  return {
    serverTime: new Date().toISOString(),
    backupVersion: backup.backup_version,
    payloadHash: backup.payload_hash,
    updatedAt: toIsoString(backup.updated_at),
    payload: normalizeStoredPayload(backup.payload_jsonb),
  };
}

const supportedBackupVersion = 1;
const maxBackupPayloadBytes = 1024 * 1024;
const validPlanStatuses = new Set([
  'active',
  'completion_ready',
  'completed',
  'archived',
]);
const validActivityActions = new Set(['complete']);

type ReadingBackupSnapshotV1 = JsonRecord & {
  v: 1;
  exportedAt: string;
  plans: JsonRecord[];
  progress: unknown[];
  activities: unknown[];
  completionEvents: JsonRecord[];
  settings: JsonRecord;
};

function parseReadingBackupSnapshot(body: unknown): ReadingBackupSnapshotV1 {
  const input = requireRecord(body);
  const rawSnapshot = isRecord(input.payload) && input.v == null
    ? input.payload
    : input;
  const snapshot = requireRecord(rawSnapshot);
  const version = readPositiveInteger(snapshot, 'v');
  if (version !== supportedBackupVersion) {
    throw new SyncInputError('unsupported_backup_version');
  }

  const exportedAt = readDateString(snapshot, 'exportedAt');
  const plans = readArray(snapshot, 'plans');
  const progress = readArray(snapshot, 'progress');
  const activities = readArray(snapshot, 'activities');
  const completionEvents = readArray(snapshot, 'completionEvents');
  const settings = snapshot.settings == null
    ? {}
    : requireRecord(snapshot.settings);

  assertMaxArrayLength('plans', plans, 250);
  assertMaxArrayLength('progress', progress, 5000);
  assertMaxArrayLength('activities', activities, 10000);
  assertMaxArrayLength('completionEvents', completionEvents, 1000);

  const planIds = validateBackupPlans(plans);
  validateBackupProgress(progress, planIds);
  validateBackupActivities(activities, planIds);
  validateBackupCompletionEvents(completionEvents, planIds);
  validateBackupSettings(settings, planIds);

  return {
    ...snapshot,
    v: supportedBackupVersion,
    exportedAt,
    plans: plans as JsonRecord[],
    progress,
    activities,
    completionEvents: completionEvents as JsonRecord[],
    settings,
  };
}

function validateBackupPlans(plans: unknown[]): Set<string> {
  const ids = new Set<string>();
  for (const raw of plans) {
    const plan = requireRecord(raw);
    const id = readString(plan, 'id');
    if (ids.has(id)) throw new SyncInputError('duplicate_plan_id');
    ids.add(id);

    readString(plan, 'templateKey');
    readOptionalString(plan, 'templateId');
    readOptionalString(plan, 'title');
    const status = readString(plan, 'status');
    if (!validPlanStatuses.has(status)) {
      throw new SyncInputError('invalid_plan_status');
    }

    readOptionalDateString(plan, 'subscribedAt');
    readOptionalDateString(plan, 'startedAt');
    readOptionalDateString(plan, 'completedAt');
    readOptionalDateString(plan, 'archivedAt');
    readOptionalDateString(plan, 'createdAt');
    readOptionalDateString(plan, 'updatedAt');
    readOptionalString(plan, 'lastOpenedSectionKey');
    readOptionalString(plan, 'lastOpenedSectionId');
    readOptionalString(plan, 'lastOpenedBookKey');
    if (plan.isActive != null && typeof plan.isActive !== 'boolean') {
      throw new SyncInputError('invalid_isActive');
    }
  }
  return ids;
}

function validateBackupProgress(progress: unknown[], planIds: Set<string>) {
  for (const raw of progress) {
    if (!Array.isArray(raw) || raw.length < 3 || raw.length > 4) {
      throw new SyncInputError('invalid_progress');
    }
    assertKnownPlanId(raw[0], planIds, 'invalid_progress_planId');
    readTupleString(raw[1], 'invalid_progress_bookKey');
    readTuplePositiveInteger(raw[2], 'invalid_progress_chapterNumber');
    if (raw[3] != null) readTupleDateString(raw[3], 'invalid_progress_completedAt');
  }
}

function validateBackupActivities(activities: unknown[], planIds: Set<string>) {
  for (const raw of activities) {
    if (!Array.isArray(raw) || raw.length !== 7) {
      throw new SyncInputError('invalid_activity');
    }
    assertKnownPlanId(raw[0], planIds, 'invalid_activity_planId');
    readTupleString(raw[1], 'invalid_activity_bookKey');
    readTuplePositiveInteger(raw[2], 'invalid_activity_chapterNumber');
    readTupleDateOnlyString(raw[3], 'invalid_activity_date');
    const action = readTupleString(raw[4], 'invalid_activity_action');
    if (!validActivityActions.has(action)) {
      throw new SyncInputError('invalid_activity_action');
    }
    readTupleString(raw[5], 'invalid_activity_timezone');
    readTupleDateString(raw[6], 'invalid_activity_happenedAt');
  }
}

function validateBackupCompletionEvents(
  completionEvents: unknown[],
  planIds: Set<string>,
) {
  for (const raw of completionEvents) {
    const event = requireRecord(raw);
    readOptionalString(event, 'id');
    assertKnownPlanId(event.planId, planIds, 'invalid_completion_planId');
    readString(event, 'templateKey');
    readDateString(event, 'completedAt');
    readPositiveInteger(event, 'completionNumber');
    readOptionalDateString(event, 'createdAt');
  }
}

function validateBackupSettings(settings: JsonRecord, planIds: Set<string>) {
  const lastActivePlanId = settings.lastActivePlanId;
  if (lastActivePlanId == null) return;
  assertKnownPlanId(lastActivePlanId, planIds, 'invalid_lastActivePlanId');
}

function countBackupSnapshot(snapshot: ReadingBackupSnapshotV1) {
  return {
    plans: snapshot.plans.length,
    progress: snapshot.progress.length,
    activities: snapshot.activities.length,
    completionEvents: snapshot.completionEvents.length,
  };
}

function normalizeStoredPayload(value: unknown): JsonRecord | null {
  if (isRecord(value)) return value;
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      return isRecord(parsed) ? parsed : null;
    } catch {
      return null;
    }
  }
  return null;
}

function canonicalJson(value: unknown): string {
  return JSON.stringify(sortJsonValue(value));
}

function sortJsonValue(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sortJsonValue);
  if (!isRecord(value)) return value;
  return Object.keys(value)
    .sort()
    .reduce<JsonRecord>((result, key) => {
      result[key] = sortJsonValue(value[key]);
      return result;
    }, {});
}

function assertMaxArrayLength(key: string, rows: unknown[], max: number) {
  if (rows.length > max) throw new SyncInputError(`${key}_too_large`);
}

function assertKnownPlanId(
  value: unknown,
  planIds: Set<string>,
  error: string,
) {
  const id = readTupleString(value, error);
  if (!planIds.has(id)) throw new SyncInputError(error);
}

function readArray(row: JsonRecord, key: string): unknown[] {
  const value = row[key];
  if (value == null) return [];
  if (!Array.isArray(value)) throw new SyncInputError(`invalid_${key}`);
  return value;
}

function readString(row: JsonRecord, key: string): string {
  const value = row[key];
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new SyncInputError(`invalid_${key}`);
  }
  return value;
}

function readOptionalString(row: JsonRecord, key: string): string | null {
  const value = row[key];
  if (value == null) return null;
  if (typeof value !== 'string') throw new SyncInputError(`invalid_${key}`);
  return value;
}

function readPositiveInteger(row: JsonRecord, key: string): number {
  const value = row[key];
  if (typeof value !== 'number' || !Number.isInteger(value) || value < 1) {
    throw new SyncInputError(`invalid_${key}`);
  }
  return value;
}

function readDateString(row: JsonRecord, key: string): string {
  const value = readString(row, key);
  if (Number.isNaN(Date.parse(value))) throw new SyncInputError(`invalid_${key}`);
  return value;
}

function readOptionalDateString(row: JsonRecord, key: string): string | null {
  const value = row[key];
  if (value == null) return null;
  if (typeof value !== 'string' || Number.isNaN(Date.parse(value))) {
    throw new SyncInputError(`invalid_${key}`);
  }
  return value;
}

function readTupleString(value: unknown, error: string): string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new SyncInputError(error);
  }
  return value;
}

function readTuplePositiveInteger(value: unknown, error: string): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < 1) {
    throw new SyncInputError(error);
  }
  return value;
}

function readTupleDateString(value: unknown, error: string): string {
  const text = readTupleString(value, error);
  if (Number.isNaN(Date.parse(text))) throw new SyncInputError(error);
  return text;
}

function readTupleDateOnlyString(value: unknown, error: string): string {
  const text = readTupleString(value, error);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(text)) throw new SyncInputError(error);
  return text;
}

function toIsoString(value: unknown): string | null {
  if (value == null) return null;
  if (value instanceof Date) return value.toISOString();
  if (typeof value === 'string') {
    const date = new Date(value);
    if (!Number.isNaN(date.getTime())) return date.toISOString();
  }
  return null;
}

function requireRecord(value: unknown): JsonRecord {
  if (!isRecord(value)) throw new SyncInputError('invalid_row');
  return value;
}

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
