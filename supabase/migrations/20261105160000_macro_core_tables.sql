-- Applied to project acfprojdjumrfmicbtsp on 2026-11-05 (migration "macro_core_tables").
-- Macro: one row of settings per person, one row per logged day, one row per weigh-in.
create table public.profiles (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  constraint profiles_data_object check (jsonb_typeof(data) = 'object'),
  constraint profiles_data_size check (pg_column_size(data) < 200000)
);
create table public.days (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  items jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, date),
  constraint days_items_array check (jsonb_typeof(items) = 'array'),
  constraint days_items_size check (pg_column_size(items) < 1000000)
);
create table public.weights (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  kg numeric(5,2) not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, date),
  constraint weights_kg_range check (kg between 30 and 400)
);
create function public.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;
create trigger profiles_touch before update on public.profiles for each row execute function public.touch_updated_at();
create trigger days_touch before update on public.days for each row execute function public.touch_updated_at();
create trigger weights_touch before update on public.weights for each row execute function public.touch_updated_at();
alter table public.profiles enable row level security;
alter table public.days enable row level security;
alter table public.weights enable row level security;
create policy "own profile: read"   on public.profiles for select to authenticated using ((select auth.uid()) = user_id);
create policy "own profile: add"    on public.profiles for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own profile: change" on public.profiles for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own profile: remove" on public.profiles for delete to authenticated using ((select auth.uid()) = user_id);
create policy "own days: read"   on public.days for select to authenticated using ((select auth.uid()) = user_id);
create policy "own days: add"    on public.days for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own days: change" on public.days for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own days: remove" on public.days for delete to authenticated using ((select auth.uid()) = user_id);
create policy "own weights: read"   on public.weights for select to authenticated using ((select auth.uid()) = user_id);
create policy "own weights: add"    on public.weights for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own weights: change" on public.weights for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own weights: remove" on public.weights for delete to authenticated using ((select auth.uid()) = user_id);
revoke all on public.profiles, public.days, public.weights from anon;
grant select, insert, update, delete on public.profiles, public.days, public.weights to authenticated;
revoke execute on function public.touch_updated_at() from public, anon, authenticated;
