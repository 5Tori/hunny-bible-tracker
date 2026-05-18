alter table today_messages
  add column if not exists share_image_url text,
  add column if not exists share_image_public_id text;
