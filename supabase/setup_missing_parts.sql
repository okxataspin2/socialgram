-- ============================================================
-- SocialGram - MISSING SETUP (buckets, storage policies, triggers)
-- Idempotent: safe to run once or multiple times.
-- HOW TO RUN: Supabase Dashboard -> SQL Editor -> paste -> Run
-- Fixes: "Database error saving new user" on signup,
--        avatar/post/story uploads failing ("Something went wrong!").
-- ============================================================

-- 1) PowerSync publication (offline sync)
do $$ begin
  if not exists (select 1 from pg_publication where pubname = 'powersync') then
    create publication powersync for all tables;
  end if;
end $$;

-- 2) Call history table (missing "calls" table)
create table if not exists public.calls (
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
drop policy if exists "Users can view their own calls." on public.calls;
create policy "Users can view their own calls." on public.calls
  for select to authenticated using (auth.uid() = caller_id or auth.uid() = callee_id);
drop policy if exists "Only authenticated users can create call records." on public.calls;
create policy "Only authenticated users can create call records." on public.calls
  for insert to authenticated with check (true);

-- 3) Storage buckets (none existed)
insert into storage.buckets (id, name) values ('avatars', 'avatars') on conflict (id) do nothing;
insert into storage.buckets (id, name) values ('posts', 'posts') on conflict (id) do nothing;
insert into storage.buckets (id, name) values ('stories', 'stories') on conflict (id) do nothing;
insert into storage.buckets (id, name) values ('messages', 'messages') on conflict (id) do nothing;

update storage.buckets set public = true where id = 'posts';

-- 4) STORAGE POLICIES
drop policy if exists "Avatar images are publicly accessible." on storage.objects;
create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');
drop policy if exists "Anyone can upload an avatar." on storage.objects;
create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');
drop policy if exists "Anyone can update their own avatar." on storage.objects;
create policy "Anyone can update their own avatar." on storage.objects
  for update using (auth.uid() = owner) with check (bucket_id = 'avatars');
drop policy if exists "Anyone can delete their own avatar." on storage.objects;
create policy "Anyone can delete their own avatar." on storage.objects for delete using (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Only authenticated users can see post media." on storage.objects;
create policy "Only authenticated users can see post media." on storage.objects for select
  to authenticated using (bucket_id = 'posts');
drop policy if exists "Only authenticated users can upload post media." on storage.objects;
create policy "Only authenticated users can upload post media." on storage.objects for insert
  to authenticated with check (bucket_id = 'posts');
drop policy if exists "Only authenticated can delete posts media." on storage.objects;
create policy "Only authenticated can delete posts media." on storage.objects for delete
  to authenticated using (bucket_id = 'posts');
drop policy if exists "Only authenticated can update posts media." on storage.objects;
create policy "Only authenticated can update posts media." on storage.objects for update
  to authenticated using (bucket_id = 'posts');

drop policy if exists "Only authenticated user can see stories media." on storage.objects;
create policy "Only authenticated user can see stories media." on storage.objects for select
  to authenticated using (bucket_id = 'stories');
drop policy if exists "Only authenticated can upload stories media." on storage.objects;
create policy "Only authenticated can upload stories media." on storage.objects for insert
  to authenticated with check (bucket_id = 'stories');
drop policy if exists "Only authenticated can delete stories media." on storage.objects;
create policy "Only authenticated can delete stories media." on storage.objects for delete
  to authenticated using (bucket_id = 'stories');
drop policy if exists "Only authenticated can update stories media." on storage.objects;
create policy "Only authenticated can update stories media." on storage.objects for update
  to authenticated using (bucket_id = 'stories');

drop policy if exists "Only participants can see message media." on storage.objects;
create policy "Only participants can see message media." on storage.objects for select
  to authenticated
  using (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text from public.participants where user_id = auth.uid()
    )
  );
drop policy if exists "Only participants can upload message media." on storage.objects;
create policy "Only participants can upload message media." on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text from public.participants where user_id = auth.uid()
    )
  );
drop policy if exists "Only participants can delete message media." on storage.objects;
create policy "Only participants can delete message media." on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text from public.participants where user_id = auth.uid()
    )
  );
drop policy if exists "Only participants can update message media." on storage.objects;
create policy "Only participants can update message media." on storage.objects for update
  to authenticated
  using (
    bucket_id = 'messages'
    and (storage.foldername(name))[1] in (
      select conversation_id::text from public.participants where user_id = auth.uid()
    )
  );

-- 5) PROFILE TRIGGERS - THE signup fix
-- ("Database error saving new user" in Supabase logs = missing/broken trigger)
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

drop trigger if exists on_auth_user_created on auth.users;
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

drop trigger if exists on_auth_user_updated on auth.users;
create trigger on_auth_user_updated
  after update on auth.users for each row
  execute procedure public.handle_update_user();

-- 6) MEDIA CLEANUP TRIGGERS + INDEXES (idempotent)
create or replace function public.handle_delete_post_media()
returns trigger as $$
begin
  delete from storage.objects where bucket_id = 'posts' and (storage.foldername(name))[1] = old.id::text;
  return old;
end;
$$ language plpgsql;

drop trigger if exists on_post_deleted on public.posts;
create trigger on_post_deleted
  after delete on posts for each row
  execute function handle_delete_post_media();

create or replace function public.handle_delete_story_media()
returns trigger as $$
begin
  delete from storage.objects where bucket_id = 'stories' and (storage.foldername(name))[1] = old.id::text;
  return old;
end;
$$ language plpgsql;

drop trigger if exists on_story_deleted on public.stories;
create trigger on_story_deleted
  after delete on stories for each row
  execute function handle_delete_story_media();

create index if not exists messages_conversation_created_at_idx on public.messages (conversation_id, created_at desc);
create index if not exists messages_from_id_idx on public.messages (from_id);
create index if not exists comments_post_id_created_at_idx on public.comments (post_id, created_at asc);
create index if not exists likes_post_id_idx on public.likes (post_id);
create index if not exists likes_user_id_idx on public.likes (user_id);
create index if not exists subscriptions_subscriber_id_idx on public.subscriptions (subscriber_id);
create index if not exists subscriptions_subscribed_to_id_idx on public.subscriptions (subscribed_to_id);
create index if not exists posts_created_at_idx on public.posts (created_at desc);
create index if not exists calls_caller_id_idx on public.calls (caller_id);
create index if not exists calls_callee_id_idx on public.calls (callee_id);
create index if not exists calls_timestamp_idx on public.calls (timestamp);

-- DONE. Signup/login/uploads should now work.