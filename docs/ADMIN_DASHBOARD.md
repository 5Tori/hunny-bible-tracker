# Admin Dashboard

Personal utility UI for managing Hunny Bible Tracker content. The admin area uses a **minimal black/white design** separate from the public marketing site.

## Visual system

| Token | Use |
|-------|-----|
| White / near-black | Page background, text, borders |
| Blue (`#2563eb`) | Primary actions: Save, New, Edit links |
| Green (`#16a34a`) | Publish, success states |
| Red (`#dc2626`) | Delete, errors |

Styles live in `apps/web/src/styles/admin-tokens.css` and `admin.css`, loaded only from `apps/web/src/app/admin/layout.tsx`. No admin rules remain in `globals.css`.

## Access

- Admin users are listed in `ADMIN_EMAILS`.
- Sign in at `/admin/login` with Google (Supabase Auth).
- API calls send the Supabase access token as `Authorization: Bearer`.

## Layout

- **Sidebar** (220px): Plans, Content, Today's messages, Log out.
- **Main** (max 1200px): Page header with a single primary CTA (e.g. New plan).
- **Editors**: Two columns — form on the left, sticky actions + preview on the right.

## Folder structure

```text
apps/web/src/
  styles/admin-tokens.css
  styles/admin.css
  components/admin/
    layout/AdminShell.tsx, AdminSidebar.tsx
    ui/Button, Badge, Alert, PageHeader, FilterTabs, DataTable, FormField, …
    catalog/useCatalogList.ts, PlanCatalogRowActions.tsx
    editors/plan/PlanEditor.tsx + sections
    editors/content/ContentEditor.tsx
    editors/today-message/TodayMessageEditor.tsx
    hooks/use-admin-auth.ts, use-admin-api.ts
  lib/admin/navigation.ts
```

## Pages

| Route | Purpose |
|-------|---------|
| `/admin/login` | Google sign-in (no sidebar) |
| `/admin/plans` | Plan catalog with Active / Archived / All |
| `/admin/plans/new`, `/admin/plans/[id]` | Plan editor |
| `/admin/content` | Content catalog |
| `/admin/content/new`, `/admin/content/[id]` | Content editor |
| `/admin/today-messages` | Today's messages catalog |
| `/admin/today-messages/new`, `/admin/today-messages/[id]` | Today message editor + share preview |

## API surface (unchanged)

Plan, content, and today-message admin routes under `/api/v1/admin/*` are unchanged by this UI refactor. See existing sections in this repo for upload endpoints and public mobile APIs.

## Manual check

1. `/admin/login` — minimal card, no brand colors.
2. Sidebar navigation and log out.
3. Each catalog: filters, table, Edit + More menu.
4. Each editor: save, publish checkbox, image upload where applicable.
5. Public `/` marketing page unchanged (no admin CSS bleed).
