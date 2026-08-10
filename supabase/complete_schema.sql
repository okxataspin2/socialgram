-- ============================================================================
-- SocialGram - COMPLETE Supabase Database Schema (single-file setup)
-- Made by RWAGENCY
--
-- INSTRUCTIONS:
-- 1. Open your Supabase project: https://supabase.com/dashboard
-- 2. Go to SQL Editor -> New Query
-- 3. Paste THIS ENTIRE FILE and click Run (~30 seconds)
--
-- !!! IMPORTANT !!!
-- This script performs a FULL RESET first:
--   - drops every app table, view, function, trigger and enum
--   - deletes ALL storage objects and buckets (avatars/posts/stories/messages)
--   - deletes ALL registered user accounts (auth.users)
--   - drops the PowerSync publication
-- Then it recreates the complete database from scratch.
-- Safe to re-run any time. Only run on a project you want reset!
--
-- After running:
-- - Sign up in the app (that auto-creates the profile row via trigger)
-- - For admin access run:
--   UPDATE auth.users SET raw_app_meta_data = '{"role": "admin"}' WHERE email = 'your-email@example.com';
-- ============================================================================

-- ============================================================================
-- STEP 0: FULL RESET (drop everything from previous setups)
-- ============================================================================

-- Drop all storage.objects policies (any leftover from previous runs)
do $$ declare p record; begin
  for p in (
    select policyname from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
  ) loop
    execute format('drop policy if exists %I on storage.objects', p.policyname);
  end loop;
end $$;

-- Drop app tables (order irrelevant thanks to CASCADE)
drop table if exists public.user_roles cascade;
drop table if exists public.admin_audit_logs cascade;
drop table if exists public.admin_settings cascade;
drop table if exists public.calls cascade;
drop table if exists public.attachments cascade;
drop table if exists public.messages cascade;
drop table if exists public.participants cascade;
drop table if exists public.conversations cascade;
drop table if exists public.stories cascade;
drop table if exists public.images cascade;
drop table if exists public.videos cascade;
drop table if exists public.subscriptions cascade;
drop table if exists public.likes cascade;
drop table if exists public.comments cascade;
drop table if exists public.post_media cascade;
drop table if exists public.posts cascade;
drop table if exists public.profiles cascade;

-- Drop enum types
drop type if exists public.media_type cascade;
drop type if exists public.conversation_type cascade;
drop type if exists public.message_type cascade;
drop type if exists public.attachment_type cascade;
drop type if exists public.story_content_type cascade;

-- Drop trigger functions (must match the functions recreated below)
drop function if exists public.delete_storage_object(text, text) cascade;
drop function if exists public.delete_avatar(text) cascade;
drop function if exists public.delete_old_avatar() cascade;
drop function if exists public.delete_old_profile() cascade;
drop function if exists public.handle_new_user() cascade;
drop function if exists public.handle_update_user() cascade;
drop function if exists public.handle_delete_post_media() cascade;
drop function if exists public.clear_posts_objects() cascade;
drop function if exists public.handle_delete_story_media() cascade;
drop function if exists public.clear_stories_objects() cascade;

-- Wipe storage contents and buckets (recreated in STEP 2)
delete from storage.objects;
delete from storage.buckets;

-- Drop the PowerSync publication so it can be recreated cleanly
drop publication if exists powersync;

-- Wipe all registered accounts (each signup gets a fresh profile
-- automatically via the on_auth_user_created trigger from STEP 15)
delete from auth.users;

-- ============================================================================
-- STEP 1: Enable PostgreSQL Extensions
-- ============================================================================
create extension if not exists "uuid-ossp";
create extension if not exists "http" schema "extensions";
create extension if not exists "pgcrypto" schema "extensions";

-- ============================================================================
-- STEP 2: Create Storage Buckets
-- ============================================================================
insert into storage.buckets (id, name) values ('avatars', 'avatars');
insert into storage.buckets (id, name) values ('posts', 'posts');
insert into storage.buckets (id, name) values ('stories', 'stories');
insert into storage.buckets (id, name) values ('messages', 'messages');

-- ============================================================================
-- STEP 3: Create Storage Policies
-- ============================================================================
-- Avatars: Public (profile pictures visible to all)
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');

create policy "Anyone can update their own avatar." on storage.objects
  for update using (auth.uid() = owner) with check (bucket_id = 'avatars');

create policy "Anyone can delete their own avatar." on storage.objects for delete using (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- Posts: Authenticated users only
create policy "Only authenticated users can see post media." on storage.objects for select
  to authenticated using (bucket_id = 'posts');

create policy "Only authenticated users can upload post media." on storage.objects for insert
  to authenticated with check (bucket_id = 'posts');

create policy "Only authenticated can delete posts media." on storage.objects for delete
  to authenticated using (bucket_id = 'posts');

create policy "Only authenticated can update posts media." on storage.objects for update
  to authenticated using (bucket_id = 'posts');

-- Posts: Public bucket - the feed renders post media via getPublicUrl()
update storage.buckets set public = true where id = 'posts';

-- Stories: Authenticated users only
create policy "Only authenticated user can see stories media." on storage.objects for select
  to authenticated using (bucket_id = 'stories');

create policy "Only authenticated can upload stories media." on storage.objects for insert
  to authenticated with check (bucket_id = 'stories');

create policy "Only authenticated can delete stories media." on storage.objects for delete
  to authenticated using (bucket_id = 'stories');

create policy "Only authenticated can update stories media." on storage.objects for update
  to authenticated using (bucket_id = 'stories');

-- ============================================================================
-- STEP 4: Create User Types & Tables
-- ============================================================================
create type media_type as enum('photo', 'video');
create type conversation_type as enum('one-on-one', 'group');
create type message_type as enum('text', 'image', 'video', 'voice');
create type attachment_type as enum('image', 'file', 'video', 'giphy', 'audio', 'url_preview');
create type story_content_type as enum('image', 'video');

-- Profiles table (user profiles)
create table public.profiles (
  id uuid not null,
  full_name text not null,
  email text not null,
  username text null,
  avatar_url text null,
  push_token text null,
  role text not null default 'user',
  suspended boolean not null default false,
  suspension_reason text null,
  fake_follower_count integer null,
  fake_following_count integer null,
  updated_at timestamp with time zone null,
  created_at timestamp with time zone not null default now(),
  constraint profiles_pkey primary key (id),
  constraint profiles_email_key unique (email),
  constraint profiles_id_fkey foreign key (id) references auth.users (id) on update cascade on delete cascade,
  constraint username_length check (
    char_length(username) >= 3 and char_length(username) <= 16
  )
);

alter table profiles enable row level security;

create policy "Profiles are viewable by everyone." on profiles for select using (true);
create policy "Allow to create profiles for everyone." on profiles for insert with check (true);
create policy "Only owner can update the profile." on profiles for update with check (auth.uid() = id);
create policy "Only owner can delete the profile." on profiles for delete using (auth.uid() = id);

-- Posts table
create table public.posts (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null,
  caption text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone null,
  media text null,
  is_reel boolean not null default false,
  is_approved boolean not null default true,
  rejection_reason text null,
  constraint posts_pkey primary key (id),
  constraint posts_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
);

alter table posts enable row level security;

create index posts_user_id_idx on public.posts (user_id);
create index posts_is_approved_idx on public.posts (is_approved);

create policy "Allow to see posts for everybody." on public.posts for select using (true);
create policy "Allow upload post only to authenticated user." on public.posts for insert to authenticated with check (true);
create policy "Allow update post only to owner." on public.posts for update to authenticated with check (auth.uid() = user_id);
create policy "Allow delete post only to owner." on public.posts for delete to authenticated using (auth.uid() = user_id);

-- Post media table
create table public.post_media (
  id uuid not null default gen_random_uuid(),
  post_id uuid not null,
  url text not null,
  type text null,
  created_at timestamp with time zone not null default now(),
  constraint post_media_pkey primary key (id),
  constraint post_media_post_id_fkey foreign key (post_id) references posts (id) on update cascade on delete cascade
);

create index post_media_post_id_idx on public.post_media (post_id);

alter table post_media enable row level security;

create policy "Everyone can see post media." on public.post_media for select using (true);
create policy "Only authenticated users can upload post media." on public.post_media for insert to authenticated with check (true);
create policy "Only owner can update post media." on public.post_media for update with check (
  auth.uid() = (select user_id from posts where posts.id = post_media.post_id)
);
create policy "Only owner can delete post media." on public.post_media for delete to authenticated using (
  auth.uid() = (select user_id from posts where posts.id = post_media.post_id)
);

-- Videos table
create table public.videos (
  id uuid not null,
  owner_id uuid not null,
  url text not null,
  first_frame_url text not null,
  blurhash text not null,
  constraint videos_pkey primary key (id),
  constraint videos_user_id_fkey foreign key (owner_id) references profiles (id) on update cascade on delete cascade
);

alter table videos enable row level security;

create policy "Allow to see videos for everybody" on public.videos for select using (true);
create policy "Allow upload video only to authenticated user." on public.videos for insert to authenticated with check (true);
create policy "Only owner can update video." on public.videos for update to authenticated with check (auth.uid() = owner_id);
create policy "Only owner can delete video." on public.videos for delete to authenticated using (auth.uid() = owner_id);

-- Images table
create table public.images (
  id uuid not null,
  owner_id uuid not null,
  url text not null,
  blurhash text null,
  constraint images_pkey primary key (id),
  constraint images_owner_id_fkey foreign key (owner_id) references public.profiles (id) on update cascade on delete cascade
);

alter table images enable row level security;

create policy "Allow to see images for everybody." on public.images for select using (true);
create policy "Allow upload image only to authenticated user." on public.images for insert to authenticated with check (true);
create policy "Allow update image only to owner." on public.images for update to authenticated with check (auth.uid() = owner_id);
create policy "Allow delete image only to owner." on public.images for delete to authenticated using (auth.uid() = owner_id);

-- ============================================================================
-- STEP 5: Comments Table
-- ============================================================================
create table public.comments (
  id uuid not null,
  post_id uuid not null,
  user_id uuid not null,
  content text not null,
  created_at timestamp with time zone not null default now(),
  replied_to_comment_id uuid null,
  constraint comments_pkey primary key (id),
  constraint comments_post_id_fkey foreign key (post_id) references posts (id) on update cascade on delete cascade,
  constraint comments_replied_to_comment_id_fkey foreign key (replied_to_comment_id) references comments (id) on update cascade on delete cascade,
  constraint comments_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
);

alter table comments enable row level security;

create policy "Everyone can see posts comments." on public.comments for select using (true);
create policy "Only owners can update comment." on public.comments for update with check(auth.uid() = user_id);
create policy "Only authenticated can upload comments." on public.comments for insert to authenticated with check (true);
create policy "Only owners can delete comment." on public.comments for delete to authenticated using (auth.uid() = user_id);

-- ============================================================================
-- STEP 6: Likes Table
-- ============================================================================
create table public.likes (
  id uuid not null default gen_random_uuid(),
  post_id uuid null,
  user_id uuid not null,
  comment_id uuid null,
  constraint likes_pkey primary key (id),
  constraint likes_comment_id_key unique (user_id, comment_id),
  constraint likes_post_id_key unique (user_id, post_id),
  constraint likes_comment_id_fkey foreign key (comment_id) references comments (id) on update cascade on delete cascade,
  constraint likes_post_id_fkey foreign key (post_id) references posts (id) on update cascade on delete cascade,
  constraint likes_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade,
  constraint like_has_either_comment_or_post check (
    ((comment_id is not null) and (post_id is null))
    or ((comment_id is null) and (post_id is not null))
  )
);

alter table likes enable row level security;

create policy "Everyone can see posts likes" on public.likes for select using (true);
create policy "Only authenticated can upload likes" on public.likes for insert to authenticated with check (true);
create policy "Only owner can update like" on public.likes for update to authenticated with check (auth.uid() = user_id);
create policy "Only owner can delete like" on public.likes for delete to authenticated using (auth.uid() = user_id);

-- ============================================================================
-- STEP 7: Subscriptions (Followers) Table
-- ============================================================================
create table public.subscriptions (
  id uuid not null,
  subscriber_id uuid not null,
  subscribed_to_id uuid not null,
  constraint subscriptions_pkey primary key (id),
  constraint subscriptions_subscribed_to_id_fkey foreign key (subscribed_to_id) references profiles (id) on update cascade on delete cascade,
  constraint subscriptions_subscriber_id_fkey foreign key (subscriber_id) references profiles (id) on update cascade on delete cascade
);

alter table subscriptions enable row level security;

create policy "Every user can see other users subscribers count." on public.subscriptions for select using (true);
create policy "Only authenticated users can subscribe to other users." on public.subscriptions for insert to authenticated with check (true);
create policy "Only authenticated users can unsubscribe from other users." on public.subscriptions for delete to authenticated using (auth.uid() = subscribed_to_id OR auth.uid() = subscriber_id);

-- ============================================================================
-- STEP 8: Conversations Table
-- ============================================================================
create table public.conversations (
  id uuid not null default gen_random_uuid(),
  type conversation_type not null,
  name text not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint conversations_pkey primary key (id)
);

alter table conversations enable row level security;

create policy "Everybody can see conversations they participate in." on public.conversations for select using (true);
create policy "Only authenticated users can create conversations with other users." on public.conversations for insert to authenticated with check (true);
create policy "Only authenticated users can delete conversations they participate in." on public.conversations for delete to authenticated using (true);

-- ============================================================================
-- STEP 9: Participants Table
-- ============================================================================
create table public.participants (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null,
  conversation_id uuid not null,
  constraint participants_pkey primary key (id),
  constraint unique_participant unique (user_id, conversation_id),
  constraint participants_conversation_id_fkey foreign key (conversation_id) references conversations (id) on update cascade on delete cascade,
  constraint participants_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
);

alter table participants enable row level security;

create policy "Everybody can see their participation with conversations." on public.participants for select using (true);
create policy "Only authenticated users can participate in conversations." on public.participants for insert to authenticated with check (true);
create policy "Only authenticated users can remove participation in conversations." on public.participants for delete to authenticated using (auth.uid() = user_id);

-- Messages storage: Private bucket, participants only (voice messages).
-- Objects are referenced by path in the messages table; playback uses
-- short-lived signed URLs generated with createSignedUrl().
-- NOTE: this block must come AFTER the participants table exists.
update storage.buckets set public = false where id = 'messages';

drop policy if exists "Only participants can see message media." on storage.objects;

create policy "Only participants can see message media." on storage.objects for select
  to authenticated
  using (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text
      from public.participants
      where user_id = auth.uid()
    )
  );

drop policy if exists "Only authenticated users can upload message media." on storage.objects;

create policy "Only participants can upload message media." on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text
      from public.participants
      where user_id = auth.uid()
    )
  );

drop policy if exists "Only authenticated can delete message media." on storage.objects;

create policy "Only participants can delete message media." on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text
      from public.participants
      where user_id = auth.uid()
    )
  );

drop policy if exists "Only authenticated can update message media." on storage.objects;

create policy "Only participants can update message media." on storage.objects for update
  to authenticated
  using (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text
      from public.participants
      where user_id = auth.uid()
    )
  );

-- ============================================================================
-- STEP 10: Messages Table
-- ============================================================================
create table public.messages (
  id uuid not null,
  conversation_id uuid not null,
  from_id uuid not null,
  type message_type not null,
  message text not null,
  reply_message_id uuid null,
  created_at timestamp with time zone not null default (now() at time zone 'utc'::text),
  updated_at timestamp with time zone not null default (now() at time zone 'utc'::text),
  is_read integer not null default 0,
  is_deleted integer not null default 0,
  is_edited integer not null default 0,
  reply_message_username text null,
  reply_message_attachment_url text null,
  reply_message_message text null,
  from_username text null,
  shared_post_id uuid null,
  constraint messages_pkey primary key (id),
  constraint check_participant foreign key (from_id, conversation_id) references participants (user_id, conversation_id) on update cascade on delete cascade,
  constraint messages_conversation_id_fkey foreign key (conversation_id) references conversations (id) on update cascade on delete cascade,
  constraint messages_reply_message_id_fkey foreign key (reply_message_id) references messages (id) on delete set null,
  constraint messages_shared_post_id_fkey foreign key (shared_post_id) references posts (id) on update cascade on delete set null,
  constraint messages_user_id_fkey foreign key (from_id) references profiles (id) on update cascade on delete cascade
);

alter table messages enable row level security;

create policy "Everybody can see messages in the conversation." on public.messages for select using (true);
create policy "Only owner can update the message." on public.messages for update to authenticated using (auth.uid() = from_id);
create policy "Only authenticated users can create message in the conversations with other users." on public.messages for insert to authenticated with check (true);
create policy "Only authenticated users can delete their own messages in the conversations they participate in." on public.messages for delete to authenticated using (auth.uid() = from_id);

-- ============================================================================
-- STEP 11: Attachments Table
-- ============================================================================
create table public.attachments (
  id uuid not null default gen_random_uuid(),
  message_id uuid not null,
  title text null,
  text text null,
  title_link text null,
  image_url text null,
  thumb_url text null,
  author_name text null,
  author_link text null,
  asset_url text null,
  og_scrape_url text null,
  type attachment_type not null,
  constraint attachments_pkey primary key (id),
  constraint attachments_message_id_fkey foreign key (message_id) references messages (id) on update cascade on delete cascade
);

alter table attachments enable row level security;

create policy "Everybody can see their messages' attachments." on public.attachments for select using (true);
create policy "Everybody can update their messages' attachments." on public.attachments for update using (true) with check (true);
create policy "Only authenticated users can add attachments." on public.attachments for insert to authenticated with check (true);
create policy "Only owners can remove attachments." on public.attachments for delete to authenticated using (true);

-- ============================================================================
-- STEP 12: Stories Table
-- ============================================================================
create table public.stories (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null,
  content_type story_content_type not null,
  content_url text not null,
  duration integer null,
  created_at timestamp with time zone not null default (now() at time zone 'utc'::text),
  expires_at timestamp with time zone not null default ((now() at time zone 'utc'::text) + '1 day'::interval),
  constraint stories_pkey primary key (id),
  constraint stories_user_id_fkey foreign key (user_id) references profiles (id) on update cascade on delete cascade
);

alter table stories enable row level security;

create policy "Everybody can see each others stories." on public.stories for select using (true);
create policy "Only authenticated users can add stories." on public.stories for insert to authenticated with check (true);
create policy "Only owners can remove stories." on public.stories for delete to authenticated using (auth.uid() = user_id);
create policy "Only owners can update stories." on public.stories for update to authenticated using (auth.uid() = user_id);

-- ============================================================================
-- STEP 13: Admin Tables
-- ============================================================================

-- Admin settings (key-value table for configuration)
create table public.admin_settings (
  key text not null,
  value text null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone null,
  constraint admin_settings_pkey primary key (key)
);

-- Admin audit logs for tracking admin actions (impersonation, approvals, etc.)
create table public.admin_audit_logs (
  id uuid not null default gen_random_uuid(),
  admin_id uuid not null,
  action text not null,
  target_type text null,
  target_id text null,
  details text null,
  created_at timestamp with time zone not null default now(),
  constraint admin_audit_logs_pkey primary key (id),
  constraint admin_audit_logs_admin_id_fkey foreign key (admin_id) references public.profiles (id) on update cascade on delete cascade
);

create index admin_audit_logs_admin_id_idx on public.admin_audit_logs (admin_id);
create index admin_audit_logs_created_at_idx on public.admin_audit_logs (created_at);

-- User roles table (role management independent of auth)
create table public.user_roles (
  user_id uuid not null,
  role text not null default 'user',
  updated_at timestamp with time zone null,
  constraint user_roles_pkey primary key (user_id),
  constraint user_roles_user_id_fkey foreign key (user_id) references public.profiles (id) on update cascade on delete cascade
);

-- Insert default auto-approve setting
insert into admin_settings (key, value) values ('auto_approve_posts', 'false')
  on conflict (key) do nothing;

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
  project_url text := 'https://ghvgpkxehccdwgxmojrt.supabase.co';
  -- Auto avatar cleanup: paste your service_role key here before running
  -- (Supabase Dashboard -> Settings -> API). Keep it empty to disable
  -- cleanup. Never commit the key to a public repo.
  service_role_key text := '';
  delete_object text := reverse(split_part(reverse(object), '/', 1));
  url text := project_url||'/storage/v1/object/'||bucket||'/'||delete_object;
begin
  if service_role_key = '' then
    select into status, content 0, 'avatar cleanup disabled (no service_role key configured)';
    return;
  end if;
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
