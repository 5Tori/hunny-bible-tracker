/** Canonical plan catalog strings shared with the mobile client (see `PlanTemplates` / seed data). */

export const TESTAMENT_SCOPE_VALUES = ['whole_bible', 'old_testament', 'new_testament'] as const;
export type TestamentScopeValue = (typeof TESTAMENT_SCOPE_VALUES)[number];

export const DIFFICULTY_VALUES = ['easy', 'medium', 'hard'] as const;
export type DifficultyValue = (typeof DIFFICULTY_VALUES)[number];

export const TESTAMENT_SCOPE_OPTIONS: Array<{ value: string; label: string }> = [
  { value: '', label: 'Not set' },
  { value: 'whole_bible', label: 'Whole Bible' },
  { value: 'old_testament', label: 'Old Testament' },
  { value: 'new_testament', label: 'New Testament' },
];

export const DIFFICULTY_OPTIONS: Array<{ value: string; label: string }> = [
  { value: '', label: 'Not set' },
  { value: 'easy', label: 'Easy' },
  { value: 'medium', label: 'Medium' },
  { value: 'hard', label: 'Hard' },
];

const TESTAMENT_SCOPE_CANONICAL = new Set<string>(TESTAMENT_SCOPE_VALUES);

const TESTAMENT_SCOPE_ALIASES: Record<string, TestamentScopeValue> = {
  whole_bible: 'whole_bible',
  whole: 'whole_bible',
  both: 'whole_bible',
  entire_bible: 'whole_bible',
  full_bible: 'whole_bible',
  ot_and_nt: 'whole_bible',
  old_testament: 'old_testament',
  old: 'old_testament',
  ot: 'old_testament',
  hebrew_bible: 'old_testament',
  new_testament: 'new_testament',
  new: 'new_testament',
  nt: 'new_testament',
};

const DIFFICULTY_CANONICAL = new Set<string>(DIFFICULTY_VALUES);

const DIFFICULTY_ALIASES: Record<string, DifficultyValue> = {
  easy: 'easy',
  beginner: 'easy',
  light: 'easy',
  simple: 'easy',
  medium: 'medium',
  moderate: 'medium',
  mid: 'medium',
  normal: 'medium',
  hard: 'hard',
  difficult: 'hard',
  advanced: 'hard',
  challenging: 'hard',
};

function slugKey(raw: string) {
  return raw
    .trim()
    .toLowerCase()
    .replace(/[\s-]+/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '');
}

/** Returns a canonical scope or `''` when unset or unrecognized. */
export function normalizeTestamentScope(raw: string | null | undefined): string {
  const key = slugKey(String(raw ?? ''));
  if (!key) return '';
  if (TESTAMENT_SCOPE_CANONICAL.has(key)) return key as TestamentScopeValue;
  const mapped = TESTAMENT_SCOPE_ALIASES[key];
  return mapped ?? '';
}

/** Returns a canonical difficulty or `''` when unset or unrecognized. */
export function normalizeDifficulty(raw: string | null | undefined): string {
  const key = slugKey(String(raw ?? ''));
  if (!key) return '';
  if (DIFFICULTY_CANONICAL.has(key)) return key as DifficultyValue;
  const mapped = DIFFICULTY_ALIASES[key];
  return mapped ?? '';
}
