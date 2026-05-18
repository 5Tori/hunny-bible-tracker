alter table content_authors
  add column if not exists is_verified boolean not null default false;

create index if not exists idx_content_authors_verified_active
  on content_authors (is_verified, is_active, display_name);
