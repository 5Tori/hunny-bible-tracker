# MVP Close Testing Todo

This is the active cleanup checklist before the next closed-test build.

## Done / Do Not Re-open As Next Task

- Read Flow QA & Stabilization is complete.
- Discover and Saved/List are hidden from the MVP bottom tabs.
- Home Today’s Message frontend is implemented.
- Today’s Message admin fields are implemented:
  - hint title/summary
  - article title/body
  - related plan
  - Bible version
  - heart/share counters
- Plans screen is implemented as a full-screen Plan Manager / Plan Library.
- Current plans can be archived without losing progress/history, then restored.
- Help & feedback posts to the web API.
- Backup/restore foundation exists through sync push/bootstrap.

## Before Closed Testing Build

- Apply `apps/web/db/schema.sql` in the target Neon environment.
- Confirm `ADMIN_EMAILS` includes the admin account.
- Confirm Cloudinary env vars are set for plan and Today’s Message image upload.
- Confirm Firebase Android SHA-1 values for debug/release/Play App Signing.
- Confirm iOS Bundle ID before any iOS external testing.
- Confirm `HUNNY_API_BASE_URL` points to the deployed API for release builds.
- Run `flutter analyze`.
- Run `pnpm --dir apps/web typecheck`.
- Run release-target smoke checks on Android emulator/device.

## Content Required

- Publish at least one valid Today’s Message for closed testing.
- Verify fallback behavior: if today has no row, the latest earlier published message appears.
- Remove Bible version text from `verse_text`; use `bible_version`.
- Publish a minimum useful plan catalog:
  - Bible in a Year
  - The Story of Joseph
  - Gospel of Mark
  - Psalms for Anxiety
  - Life of David
- Confirm every published plan creates valid `user_plan_chapters`.
- Confirm related plan CTA in Today’s Message opens/starts the intended plan.

## Manual QA Checklist

- Fresh install opens Home without account.
- Home shows Today’s Message and current plan progress.
- Today’s Message heart/share update counters.
- Today’s Message save persists locally.
- Read More modal shows article and related plan card.
- Start Plan from Today’s Message opens Read with that plan active.
- Read tab title opens quick My Plans sheet.
- Browse Plans opens Plans Catalog.
- Manage Plans opens Plans My Plans.
- Current plan can be continued.
- Current plan can be archived and disappears from Current.
- Archived plan can be restored with progress intact.
- Chapter check/uncheck persists after app restart.
- Plan completion creates one completion event.
- Completed plan can Start Again as a new run.
- Settings sign-in works.
- Settings Sync now backs up rows.
- Settings Restore backup restores rows after reinstall/reset.
- Help & feedback submits successfully.

## Known Deferred Work

- Plan Detail screen.
- Rich Saved/Discover product surfaces.
- Push notifications.
- Automatic multi-device incremental merge.
- Conflict resolution UI.
- More robust automated test coverage.
- In-app admin/content preview tooling.

## Release Notes Prep

- Update `docs/ref/HUNNY_RELEASE_LOG.md` when a build artifact is created.
- Include the build number, track, package/bundle ID, and known testing focus.
- Keep Play Console notes short and tester-facing.
