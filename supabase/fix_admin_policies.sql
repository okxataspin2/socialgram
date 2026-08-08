-- Enable RLS and create policies for admin tables
alter table public.admin_settings enable row level security;
alter table public.admin_audit_logs enable row level security;
alter table public.user_roles enable row level security;

-- Admin-only access policies
create policy "Admins can view admin settings" on public.admin_settings
  for select to authenticated using (
    exists (
      select 1 from auth.users
      where auth.users.id = auth.uid()
        and (auth.users.raw_app_meta_data->>'role')::text = 'admin'
    )
  );

create policy "Admins can modify admin settings" on public.admin_settings
  for all to authenticated using (
    exists (
      select 1 from auth.users
      where auth.users.id = auth.uid()
        and (auth.users.raw_app_meta_data->>'role')::text = 'admin'
    )
  );

create policy "Admins can view audit logs" on public.admin_audit_logs
  for select to authenticated using (
    exists (
      select 1 from auth.users
      where auth.users.id = auth.uid()
        and (auth.users.raw_app_meta_data->>'role')::text = 'admin'
    )
  );

create policy "System can insert audit logs" on public.admin_audit_logs
  for insert to authenticated with check (true);

create policy "Users can view their own role" on public.user_roles
  for select to authenticated using (user_id = auth.uid());

create policy "Admins can view all roles" on public.user_roles
  for select to authenticated using (
    exists (
      select 1 from auth.users
      where auth.users.id = auth.uid()
        and (auth.users.raw_app_meta_data->>'role')::text = 'admin'
    )
  );

-- ============================================================================
-- STEP 14: Storage Cleanup Functions
-- ============================================================================
create or replace function public.delete_storage_object(bucket text, object text, out status int, out content text)
returns record
language 'plpgsql'
security definer
as $$
declare
  project_url text := '<PROJECT_URL>';
  service_role_key text := '<SERVICE_ROLE_KEY>';
  delete_object text := reverse(split_part(reverse(object), '/', 1));
  url text := project_url||'/storage/v1/object/'||bucket||'/'||delete_object;
begin
  select
    into status, content
         result.status::int, result.content::text
         FROM extensions.http((
    'DELETE',
    url,
    ARRAY[extensions.http_header('authorization','Bearer '||service_role_key)],
    NULL,
    NULL)::extensions.http_request) as result;
end;
$$;

create or replace function delete_avatar(avatar_url text, out status int, out content text)
returns record
language 'plpgsql'
security definer
as $$
begin
  select
    into status, content
         result.status, result.content
         from public.delete_storage_object('avatars', avatar_url) as result;
end;
$$;

create or replace function delete_old_avatar()
returns trigger
language 'plpgsql'
security definer
as $$
declare
  status int;
  content text;
  avatar_name text;
begin
  if coalesce(old.avatar_url, '') <> ''
      and (tg_op = 'DELETE' or (old.avatar_url <> coalesce(new.avatar_url, ''))) then
    avatar_name := old.avatar_url;
    select
      into status, content
      result.status, result.content
      from public.delete_avatar(avatar_name) as result;
    if status <> 200 then
      raise warning 'Could not delete avatar: % %', status, content;
    end if;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger before_profile_changes
  before update of avatar_url or delete on public.profiles
  for each row execute function public.delete_old_avatar();

create or replace function delete_old_profile()
returns trigger
language 'plpgsql'
security definer
as $$
begin
  delete from public.profiles where id = old.id;
  return old;
end;
$$;

create trigger before_delete_user
  before delete on auth.users
  for each row execute function public.delete_old_profile();

-- ============================================================================
-- STEP 15: Profile Creation Triggers
-- ============================================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, username, avatar_url, push_token)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.handle_update_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.profiles
  set full_name = new.raw_user_meta_data->>'name',
      email = new.email
  where id = new.id;
  return new;
end;
$$;

create trigger on_auth_user_updated
  after update on auth.users for each row
  execute procedure public.handle_update_user();

-- ============================================================================
-- STEP 16: Post Media Cleanup Triggers
-- ============================================================================
create or replace function public.handle_delete_post_media()
returns trigger as $$
BEGIN
  DELETE FROM storage.objects WHERE bucket_id = 'posts' AND (storage.foldername(name))[1] = OLD.id::text;
  RETURN OLD;
END;
$$ language plpgsql;

create trigger on_post_deleted
  after delete on posts for each row
  execute function handle_delete_post_media();

create or replace function clear_posts_objects()
returns trigger as $$
begin
  delete from storage.objects where bucket_id = 'posts';
  return null;
end;
$$ language plpgsql;

create trigger clear_posts_trigger
  after truncate on public.posts for each statement
  execute function clear_posts_objects();

-- ============================================================================
-- STEP 17: Story Media Cleanup Triggers
-- ============================================================================
create or replace function public.handle_delete_story_media()
returns trigger as $$
BEGIN
  DELETE FROM storage.objects WHERE bucket_id = 'stories' AND (storage.foldername(name))[1] = OLD.id::text;
  RETURN OLD;
END;
$$ language plpgsql;

create trigger on_story_deleted
  after delete on stories for each row
  execute function handle_delete_story_media();

create or replace function clear_stories_objects()
returns trigger as $$
begin
  delete from storage.objects where bucket_id = 'stories';
  return null;
end;
$$ language plpgsql;

create trigger clear_stories_trigger
  after truncate on public.stories for each statement
  execute function clear_stories_objects();

-- ============================================================================
-- STEP 16: Call History Table (for call logs)
-- ============================================================================

create table public.calls (
  id uuid not null default gen_random_uuid(),
  caller_id uuid not null,
  callee_id uuid not null,
  room_name text not null,
  call_type text not null check (call_type in ('video', 'audio')),
  status text not null default 'completed' check (status in ('completed', 'missed', 'declined')),
  duration_seconds integer null,
  timestamp timestamp with time zone not null default now(),
  constraint calls_pkey primary key (id),
  constraint calls_caller_id_fkey foreign key (caller_id) references profiles (id) on update cascade on delete cascade,
  constraint calls_callee_id_fkey foreign key (callee_id) references profiles (id) on update cascade on delete cascade
);

alter table calls enable row level security;

create policy "Users can view their own calls." on public.calls
  for select to authenticated using (auth.uid() = caller_id or auth.uid() = callee_id);

create policy "Only authenticated users can create call records." on public.calls
  for insert to authenticated with check (true);

create index calls_caller_id_idx on public.calls (caller_id);
create index calls_callee_id_idx on public.calls (callee_id);
create index calls_timestamp_idx on public.calls (timestamp);

-- ============================================================================
-- STEP 18: Performance Indexes
-- Keeps hot queries off full-table scans on the free tier DB.
-- ============================================================================

-- Chat feed / pagination: conversations order their message lists by created_at
create index messages_conversation_created_at_idx
  on public.messages (conversation_id, created_at desc);
-- "who sent this" queries + participant FK checks
create index messages_from_id_idx on public.messages (from_id);

-- Comments are fetched per post (comment lists) and sorted by created_at
create index comments_post_id_created_at_idx
  on public.comments (post_id, created_at asc);

-- Likes: unique checks / counts happen per post AND per user
create index likes_post_id_idx on public.likes (post_id);
create index likes_user_id_idx on public.likes (user_id);

-- Followers feed: fetch posts of everyone you follow
create index subscriptions_subscriber_id_idx on public.subscriptions (subscriber_id);
create index subscriptions_subscribed_to_id_idx on public.subscriptions (subscribed_to_id);

-- Post timeline / feed ordering
create index posts_created_at_idx on public.posts (created_at desc);

-- ============================================================================
-- PowerSync Publication for Offline Sync
-- ============================================================================
create publication powersync for all tables;

-- ============================================================================
-- DONE! Database is fully set up.
-- Next: Set your first admin user:
-- UPDATE auth.users SET raw_app_meta_data = '{"role": "admin"}' WHERE email = 'your-admin@email.com';
-- ============================================================================
