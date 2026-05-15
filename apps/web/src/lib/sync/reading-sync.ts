import { sql } from '@/lib/db/neon';

type SqlLike = typeof sql;

type JsonRecord = Record<string, unknown>;

type SyncRowAck = {
  clientId: string;
  serverId: string;
};

export type ReadingSyncPushResult = {
  serverTime: string;
  counts: {
    userReadingPlans: number;
    userPlanChapters: number;
    chapterProgressEntries: number;
    readingActivities: number;
    planCompletionEvents: number;
  };
  acknowledgements: {
    userReadingPlans: SyncRowAck[];
    userPlanChapters: SyncRowAck[];
    chapterProgressEntries: SyncRowAck[];
    readingActivities: SyncRowAck[];
    planCompletionEvents: SyncRowAck[];
  };
};

export type ReadingSyncBootstrapResult = {
  serverTime: string;
  userReadingPlans: JsonRecord[];
  userPlanChapters: JsonRecord[];
  chapterProgressEntries: JsonRecord[];
  readingActivities: JsonRecord[];
  planCompletionEvents: JsonRecord[];
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
  const input = parsePushBody(body);
  const planAcks = await upsertUserReadingPlans(
    sql,
    authUserId,
    input.userReadingPlans,
  );
  const planMap = await getPlanIdMap(sql, authUserId, [
    ...input.userReadingPlans.map((row) => row.id),
    ...input.userPlanChapters.map((row) => row.userPlanId),
    ...input.chapterProgressEntries.map((row) => row.userPlanId),
    ...input.readingActivities.map((row) => row.userPlanId),
    ...input.planCompletionEvents.map((row) => row.userPlanId),
  ]);

  const chapterAcks = await upsertUserPlanChapters(
    sql,
    authUserId,
    input.userPlanChapters,
    planMap,
  );
  const progressAcks = await upsertChapterProgressEntries(
    sql,
    authUserId,
    input.chapterProgressEntries,
    planMap,
  );
  const activityAcks = await upsertReadingActivities(
    sql,
    authUserId,
    input.readingActivities,
    planMap,
  );
  const completionAcks = await upsertPlanCompletionEvents(
    sql,
    authUserId,
    input.planCompletionEvents,
    planMap,
  );

  await sql`
    insert into sync_states (auth_user_id, last_push_at, updated_at)
    values (${authUserId}, now(), now())
    on conflict (auth_user_id)
    do update set last_push_at = now(), updated_at = now()
  `;

  return {
    serverTime: new Date().toISOString(),
    counts: {
      userReadingPlans: planAcks.length,
      userPlanChapters: chapterAcks.length,
      chapterProgressEntries: progressAcks.length,
      readingActivities: activityAcks.length,
      planCompletionEvents: completionAcks.length,
    },
    acknowledgements: {
      userReadingPlans: planAcks,
      userPlanChapters: chapterAcks,
      chapterProgressEntries: progressAcks,
      readingActivities: activityAcks,
      planCompletionEvents: completionAcks,
    },
  };
}

export async function getReadingSyncBootstrap(
  authUserId: string,
): Promise<ReadingSyncBootstrapResult> {
  const plans = (await sql`
    select
      id::text as server_id,
      client_id,
      client_local_user_id,
      template_id::text as template_id,
      title,
      status,
      subscribed_at,
      started_at,
      completed_at,
      archived_at,
      is_active,
      last_opened_section_id,
      last_opened_book_key,
      client_created_at,
      client_updated_at,
      client_revision
    from user_reading_plans
    where auth_user_id = ${authUserId}
    order by client_updated_at desc nulls last, updated_at desc
  `) as Array<Record<string, unknown>>;

  const chapters = (await sql`
    select
      id::text as server_id,
      client_id,
      client_user_plan_id,
      section_id,
      book_key,
      chapter_number,
      order_index,
      client_created_at,
      client_revision
    from user_plan_chapters
    where auth_user_id = ${authUserId}
    order by client_user_plan_id, order_index
  `) as Array<Record<string, unknown>>;

  const progress = (await sql`
    select
      id::text as server_id,
      client_id,
      client_user_plan_id,
      book_key,
      chapter_number,
      is_completed,
      completed_at,
      client_updated_at,
      client_revision
    from chapter_progress_entries
    where auth_user_id = ${authUserId}
    order by client_updated_at desc
  `) as Array<Record<string, unknown>>;

  const activities = (await sql`
    select
      id::text as server_id,
      client_id,
      client_user_plan_id,
      book_key,
      chapter_number,
      action,
      activity_date,
      timezone,
      happened_at,
      client_created_at,
      client_revision
    from reading_activities
    where auth_user_id = ${authUserId}
    order by happened_at desc
  `) as Array<Record<string, unknown>>;

  const completions = (await sql`
    select
      id::text as server_id,
      client_id,
      client_user_plan_id,
      template_id::text as template_id,
      completion_number,
      completed_at,
      client_created_at,
      client_revision
    from plan_completion_events
    where auth_user_id = ${authUserId}
    order by completed_at desc
  `) as Array<Record<string, unknown>>;

  await sql`
    insert into sync_states (auth_user_id, last_bootstrap_at, updated_at)
    values (${authUserId}, now(), now())
    on conflict (auth_user_id)
    do update set last_bootstrap_at = now(), updated_at = now()
  `;

  return {
    serverTime: new Date().toISOString(),
    userReadingPlans: plans.map(mapBootstrapPlan),
    userPlanChapters: chapters.map(mapBootstrapChapter),
    chapterProgressEntries: progress.map(mapBootstrapProgress),
    readingActivities: activities.map(mapBootstrapActivity),
    planCompletionEvents: completions.map(mapBootstrapCompletion),
  };
}

type PushInput = {
  userReadingPlans: UserReadingPlanInput[];
  userPlanChapters: UserPlanChapterInput[];
  chapterProgressEntries: ChapterProgressInput[];
  readingActivities: ReadingActivityInput[];
  planCompletionEvents: PlanCompletionEventInput[];
};

type UserReadingPlanInput = {
  id: string;
  localUserId: string | null;
  templateId: string;
  title: string;
  status: string;
  subscribedAt: string;
  startedAt: string | null;
  completedAt: string | null;
  archivedAt: string | null;
  isActive: boolean;
  lastOpenedSectionId: string | null;
  lastOpenedBookKey: string | null;
  createdAt: string;
  updatedAt: string;
  clientRevision: number;
};

type UserPlanChapterInput = {
  id: string;
  userPlanId: string;
  sectionId: string;
  bookKey: string;
  chapterNumber: number;
  orderIndex: number;
  createdAt: string;
  clientRevision: number;
};

type ChapterProgressInput = {
  id: string;
  userPlanId: string;
  bookKey: string;
  chapterNumber: number;
  isCompleted: boolean;
  completedAt: string | null;
  updatedAt: string;
  clientRevision: number;
};

type ReadingActivityInput = {
  id: string;
  userPlanId: string;
  bookKey: string;
  chapterNumber: number;
  action: string;
  activityDate: string;
  timezone: string;
  happenedAt: string;
  createdAt: string;
  clientRevision: number;
};

type PlanCompletionEventInput = {
  id: string;
  userPlanId: string;
  templateId: string;
  completionNumber: number;
  completedAt: string;
  createdAt: string;
  clientRevision: number;
};

function parsePushBody(body: unknown): PushInput {
  if (!isRecord(body)) {
    throw new SyncInputError('invalid_body');
  }
  return {
    userReadingPlans: readArray(body, 'userReadingPlans').map(parsePlan),
    userPlanChapters: readArray(body, 'userPlanChapters').map(parseChapter),
    chapterProgressEntries: readArray(body, 'chapterProgressEntries').map(parseProgress),
    readingActivities: readArray(body, 'readingActivities').map(parseActivity),
    planCompletionEvents: readArray(body, 'planCompletionEvents').map(parseCompletion),
  };
}

function mapBootstrapPlan(row: Record<string, unknown>): JsonRecord {
  return {
    serverId: row.server_id,
    id: row.client_id,
    localUserId: row.client_local_user_id,
    templateId: row.template_id,
    title: row.title,
    status: row.status,
    subscribedAt: toIsoString(row.subscribed_at),
    startedAt: toIsoString(row.started_at),
    completedAt: toIsoString(row.completed_at),
    archivedAt: toIsoString(row.archived_at),
    isActive: row.is_active,
    lastOpenedSectionId: row.last_opened_section_id,
    lastOpenedBookKey: row.last_opened_book_key,
    createdAt: toIsoString(row.client_created_at),
    updatedAt: toIsoString(row.client_updated_at),
    clientRevision: row.client_revision,
  };
}

function mapBootstrapChapter(row: Record<string, unknown>): JsonRecord {
  return {
    serverId: row.server_id,
    id: row.client_id,
    userPlanId: row.client_user_plan_id,
    sectionId: row.section_id,
    bookKey: row.book_key,
    chapterNumber: row.chapter_number,
    orderIndex: row.order_index,
    createdAt: toIsoString(row.client_created_at),
    clientRevision: row.client_revision,
  };
}

function mapBootstrapProgress(row: Record<string, unknown>): JsonRecord {
  return {
    serverId: row.server_id,
    id: row.client_id,
    userPlanId: row.client_user_plan_id,
    bookKey: row.book_key,
    chapterNumber: row.chapter_number,
    isCompleted: row.is_completed,
    completedAt: toIsoString(row.completed_at),
    updatedAt: toIsoString(row.client_updated_at),
    clientRevision: row.client_revision,
  };
}

function mapBootstrapActivity(row: Record<string, unknown>): JsonRecord {
  return {
    serverId: row.server_id,
    id: row.client_id,
    userPlanId: row.client_user_plan_id,
    bookKey: row.book_key,
    chapterNumber: row.chapter_number,
    action: row.action,
    activityDate: toDateOnlyString(row.activity_date),
    timezone: row.timezone,
    happenedAt: toIsoString(row.happened_at),
    createdAt: toIsoString(row.client_created_at),
    clientRevision: row.client_revision,
  };
}

function mapBootstrapCompletion(row: Record<string, unknown>): JsonRecord {
  return {
    serverId: row.server_id,
    id: row.client_id,
    userPlanId: row.client_user_plan_id,
    templateId: row.template_id,
    completionNumber: row.completion_number,
    completedAt: toIsoString(row.completed_at),
    createdAt: toIsoString(row.client_created_at),
    clientRevision: row.client_revision,
  };
}

function parsePlan(raw: unknown): UserReadingPlanInput {
  const row = requireRecord(raw);
  return {
    id: readString(row, 'id'),
    localUserId: readOptionalString(row, 'localUserId'),
    templateId: readString(row, 'templateId'),
    title: readString(row, 'title'),
    status: readString(row, 'status'),
    subscribedAt: readDateString(row, 'subscribedAt'),
    startedAt: readOptionalDateString(row, 'startedAt'),
    completedAt: readOptionalDateString(row, 'completedAt'),
    archivedAt: readOptionalDateString(row, 'archivedAt'),
    isActive: readBoolean(row, 'isActive'),
    lastOpenedSectionId: readOptionalString(row, 'lastOpenedSectionId'),
    lastOpenedBookKey: readOptionalString(row, 'lastOpenedBookKey'),
    createdAt: readDateString(row, 'createdAt'),
    updatedAt: readDateString(row, 'updatedAt'),
    clientRevision: readInteger(row, 'clientRevision'),
  };
}

function parseChapter(raw: unknown): UserPlanChapterInput {
  const row = requireRecord(raw);
  return {
    id: readString(row, 'id'),
    userPlanId: readString(row, 'userPlanId'),
    sectionId: readString(row, 'sectionId'),
    bookKey: readString(row, 'bookKey'),
    chapterNumber: readPositiveInteger(row, 'chapterNumber'),
    orderIndex: readInteger(row, 'orderIndex'),
    createdAt: readDateString(row, 'createdAt'),
    clientRevision: readInteger(row, 'clientRevision'),
  };
}

function parseProgress(raw: unknown): ChapterProgressInput {
  const row = requireRecord(raw);
  return {
    id: readString(row, 'id'),
    userPlanId: readString(row, 'userPlanId'),
    bookKey: readString(row, 'bookKey'),
    chapterNumber: readPositiveInteger(row, 'chapterNumber'),
    isCompleted: readBoolean(row, 'isCompleted'),
    completedAt: readOptionalDateString(row, 'completedAt'),
    updatedAt: readDateString(row, 'updatedAt'),
    clientRevision: readInteger(row, 'clientRevision'),
  };
}

function parseActivity(raw: unknown): ReadingActivityInput {
  const row = requireRecord(raw);
  return {
    id: readString(row, 'id'),
    userPlanId: readString(row, 'userPlanId'),
    bookKey: readString(row, 'bookKey'),
    chapterNumber: readPositiveInteger(row, 'chapterNumber'),
    action: readString(row, 'action'),
    activityDate: readString(row, 'activityDate'),
    timezone: readString(row, 'timezone'),
    happenedAt: readDateString(row, 'happenedAt'),
    createdAt: readDateString(row, 'createdAt'),
    clientRevision: readInteger(row, 'clientRevision'),
  };
}

function parseCompletion(raw: unknown): PlanCompletionEventInput {
  const row = requireRecord(raw);
  return {
    id: readString(row, 'id'),
    userPlanId: readString(row, 'userPlanId'),
    templateId: readString(row, 'templateId'),
    completionNumber: readPositiveInteger(row, 'completionNumber'),
    completedAt: readDateString(row, 'completedAt'),
    createdAt: readDateString(row, 'createdAt'),
    clientRevision: readInteger(row, 'clientRevision'),
  };
}

async function upsertUserReadingPlans(
  txn: SqlLike,
  authUserId: string,
  rows: UserReadingPlanInput[],
): Promise<SyncRowAck[]> {
  const acks: SyncRowAck[] = [];
  for (const row of rows) {
    const result = (await txn`
      insert into user_reading_plans (
        auth_user_id,
        client_id,
        client_local_user_id,
        template_id,
        title,
        status,
        subscribed_at,
        started_at,
        completed_at,
        archived_at,
        is_active,
        last_opened_section_id,
        last_opened_book_key,
        client_created_at,
        client_updated_at,
        client_revision,
        updated_at
      )
      values (
        ${authUserId},
        ${row.id},
        ${row.localUserId},
        ${row.templateId},
        ${row.title},
        ${row.status},
        ${row.subscribedAt},
        ${row.startedAt},
        ${row.completedAt},
        ${row.archivedAt},
        ${row.isActive},
        ${row.lastOpenedSectionId},
        ${row.lastOpenedBookKey},
        ${row.createdAt},
        ${row.updatedAt},
        ${row.clientRevision},
        now()
      )
      on conflict (auth_user_id, client_id)
      do update set
        client_local_user_id = excluded.client_local_user_id,
        template_id = excluded.template_id,
        title = excluded.title,
        status = excluded.status,
        subscribed_at = excluded.subscribed_at,
        started_at = excluded.started_at,
        completed_at = excluded.completed_at,
        archived_at = excluded.archived_at,
        is_active = excluded.is_active,
        last_opened_section_id = excluded.last_opened_section_id,
        last_opened_book_key = excluded.last_opened_book_key,
        client_created_at = excluded.client_created_at,
        client_updated_at = excluded.client_updated_at,
        client_revision = greatest(user_reading_plans.client_revision, excluded.client_revision),
        updated_at = now()
      returning id::text, client_id
    `) as Array<{ id: string; client_id: string }>;
    acks.push({ clientId: result[0].client_id, serverId: result[0].id });
  }
  return acks;
}

async function upsertUserPlanChapters(
  txn: SqlLike,
  authUserId: string,
  rows: UserPlanChapterInput[],
  planMap: Map<string, string>,
): Promise<SyncRowAck[]> {
  const acks: SyncRowAck[] = [];
  for (const row of rows) {
    const serverPlanId = requirePlanMap(planMap, row.userPlanId);
    const result = (await txn`
      insert into user_plan_chapters (
        auth_user_id,
        user_reading_plan_id,
        client_id,
        client_user_plan_id,
        section_id,
        book_key,
        chapter_number,
        order_index,
        client_created_at,
        client_revision,
        updated_at
      )
      values (
        ${authUserId},
        ${serverPlanId},
        ${row.id},
        ${row.userPlanId},
        ${row.sectionId},
        ${row.bookKey},
        ${row.chapterNumber},
        ${row.orderIndex},
        ${row.createdAt},
        ${row.clientRevision},
        now()
      )
      on conflict (auth_user_id, client_id)
      do update set
        user_reading_plan_id = excluded.user_reading_plan_id,
        client_user_plan_id = excluded.client_user_plan_id,
        section_id = excluded.section_id,
        book_key = excluded.book_key,
        chapter_number = excluded.chapter_number,
        order_index = excluded.order_index,
        client_created_at = excluded.client_created_at,
        client_revision = greatest(user_plan_chapters.client_revision, excluded.client_revision),
        updated_at = now()
      returning id::text, client_id
    `) as Array<{ id: string; client_id: string }>;
    acks.push({ clientId: result[0].client_id, serverId: result[0].id });
  }
  return acks;
}

async function upsertChapterProgressEntries(
  txn: SqlLike,
  authUserId: string,
  rows: ChapterProgressInput[],
  planMap: Map<string, string>,
): Promise<SyncRowAck[]> {
  const acks: SyncRowAck[] = [];
  for (const row of rows) {
    const serverPlanId = requirePlanMap(planMap, row.userPlanId);
    const result = (await txn`
      insert into chapter_progress_entries (
        auth_user_id,
        user_reading_plan_id,
        client_id,
        client_user_plan_id,
        book_key,
        chapter_number,
        is_completed,
        completed_at,
        client_updated_at,
        client_revision,
        updated_at
      )
      values (
        ${authUserId},
        ${serverPlanId},
        ${row.id},
        ${row.userPlanId},
        ${row.bookKey},
        ${row.chapterNumber},
        ${row.isCompleted},
        ${row.completedAt},
        ${row.updatedAt},
        ${row.clientRevision},
        now()
      )
      on conflict (auth_user_id, client_id)
      do update set
        user_reading_plan_id = excluded.user_reading_plan_id,
        client_user_plan_id = excluded.client_user_plan_id,
        book_key = excluded.book_key,
        chapter_number = excluded.chapter_number,
        is_completed = excluded.is_completed,
        completed_at = excluded.completed_at,
        client_updated_at = excluded.client_updated_at,
        client_revision = greatest(chapter_progress_entries.client_revision, excluded.client_revision),
        updated_at = now()
      returning id::text, client_id
    `) as Array<{ id: string; client_id: string }>;
    acks.push({ clientId: result[0].client_id, serverId: result[0].id });
  }
  return acks;
}

async function upsertReadingActivities(
  txn: SqlLike,
  authUserId: string,
  rows: ReadingActivityInput[],
  planMap: Map<string, string>,
): Promise<SyncRowAck[]> {
  const acks: SyncRowAck[] = [];
  for (const row of rows) {
    const serverPlanId = requirePlanMap(planMap, row.userPlanId);
    const result = (await txn`
      insert into reading_activities (
        auth_user_id,
        user_reading_plan_id,
        client_id,
        client_user_plan_id,
        book_key,
        chapter_number,
        action,
        activity_date,
        timezone,
        happened_at,
        client_created_at,
        client_revision,
        updated_at
      )
      values (
        ${authUserId},
        ${serverPlanId},
        ${row.id},
        ${row.userPlanId},
        ${row.bookKey},
        ${row.chapterNumber},
        ${row.action},
        ${row.activityDate},
        ${row.timezone},
        ${row.happenedAt},
        ${row.createdAt},
        ${row.clientRevision},
        now()
      )
      on conflict (auth_user_id, client_id)
      do update set
        user_reading_plan_id = excluded.user_reading_plan_id,
        client_user_plan_id = excluded.client_user_plan_id,
        book_key = excluded.book_key,
        chapter_number = excluded.chapter_number,
        action = excluded.action,
        activity_date = excluded.activity_date,
        timezone = excluded.timezone,
        happened_at = excluded.happened_at,
        client_created_at = excluded.client_created_at,
        client_revision = greatest(reading_activities.client_revision, excluded.client_revision),
        updated_at = now()
      returning id::text, client_id
    `) as Array<{ id: string; client_id: string }>;
    acks.push({ clientId: result[0].client_id, serverId: result[0].id });
  }
  return acks;
}

async function upsertPlanCompletionEvents(
  txn: SqlLike,
  authUserId: string,
  rows: PlanCompletionEventInput[],
  planMap: Map<string, string>,
): Promise<SyncRowAck[]> {
  const acks: SyncRowAck[] = [];
  for (const row of rows) {
    const serverPlanId = requirePlanMap(planMap, row.userPlanId);
    const result = (await txn`
      insert into plan_completion_events (
        auth_user_id,
        user_reading_plan_id,
        client_id,
        client_user_plan_id,
        template_id,
        completion_number,
        completed_at,
        client_created_at,
        client_revision,
        updated_at
      )
      values (
        ${authUserId},
        ${serverPlanId},
        ${row.id},
        ${row.userPlanId},
        ${row.templateId},
        ${row.completionNumber},
        ${row.completedAt},
        ${row.createdAt},
        ${row.clientRevision},
        now()
      )
      on conflict (auth_user_id, client_id)
      do update set
        user_reading_plan_id = excluded.user_reading_plan_id,
        client_user_plan_id = excluded.client_user_plan_id,
        template_id = excluded.template_id,
        completion_number = excluded.completion_number,
        completed_at = excluded.completed_at,
        client_created_at = excluded.client_created_at,
        client_revision = greatest(plan_completion_events.client_revision, excluded.client_revision),
        updated_at = now()
      returning id::text, client_id
    `) as Array<{ id: string; client_id: string }>;
    acks.push({ clientId: result[0].client_id, serverId: result[0].id });
  }
  return acks;
}

async function getPlanIdMap(
  txn: SqlLike,
  authUserId: string,
  clientPlanIds: string[],
): Promise<Map<string, string>> {
  const uniqueIds = Array.from(new Set(clientPlanIds.filter(Boolean)));
  const map = new Map<string, string>();
  for (const clientId of uniqueIds) {
    const rows = (await txn`
      select id::text, client_id
      from user_reading_plans
      where auth_user_id = ${authUserId} and client_id = ${clientId}
      limit 1
    `) as Array<{ id: string; client_id: string }>;
    if (rows[0]) map.set(rows[0].client_id, rows[0].id);
  }
  return map;
}

function requirePlanMap(map: Map<string, string>, clientPlanId: string) {
  const serverPlanId = map.get(clientPlanId);
  if (!serverPlanId) {
    throw new SyncInputError(`missing_user_plan:${clientPlanId}`);
  }
  return serverPlanId;
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

function readBoolean(row: JsonRecord, key: string): boolean {
  const value = row[key];
  if (typeof value !== 'boolean') throw new SyncInputError(`invalid_${key}`);
  return value;
}

function readInteger(row: JsonRecord, key: string): number {
  const value = row[key];
  if (typeof value !== 'number' || !Number.isInteger(value)) {
    throw new SyncInputError(`invalid_${key}`);
  }
  return value;
}

function readPositiveInteger(row: JsonRecord, key: string): number {
  const value = readInteger(row, key);
  if (value < 1) throw new SyncInputError(`invalid_${key}`);
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

function toIsoString(value: unknown): string | null {
  if (value == null) return null;
  if (value instanceof Date) return value.toISOString();
  if (typeof value === 'string') {
    const date = new Date(value);
    if (!Number.isNaN(date.getTime())) return date.toISOString();
  }
  return null;
}

function toDateOnlyString(value: unknown): string | null {
  if (value == null) return null;
  if (value instanceof Date) return value.toISOString().slice(0, 10);
  if (typeof value === 'string') {
    if (/^\d{4}-\d{2}-\d{2}$/.test(value)) return value;
    const date = new Date(value);
    if (!Number.isNaN(date.getTime())) return date.toISOString().slice(0, 10);
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
