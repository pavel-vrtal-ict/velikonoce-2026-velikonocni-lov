-- Supabase setup for "Velikonoční lov vajíček"
-- Creates table + RLS + a public view that hides email_hash.

create extension if not exists pgcrypto;

create table if not exists public.vajicka_scores (
  id uuid primary key default gen_random_uuid(),
  nick text not null,
  eggs int not null check (eggs >= 0 and eggs <= 12),
  ms int not null check (ms >= 0),
  ts bigint not null,
  email_hash text null,
  created_at timestamptz not null default now()
);

-- Helpful index for leaderboard ordering
create index if not exists vajicka_scores_leaderboard_idx
  on public.vajicka_scores (eggs desc, ms asc, ts desc);

-- Public view: leaderboard/statistics WITHOUT email_hash
create or replace view public.vajicka_scores_public as
select id, nick, eggs, ms, ts, created_at
from public.vajicka_scores;

alter table public.vajicka_scores enable row level security;

-- Policy: allow anyone (anon) to insert scores
drop policy if exists "scores_insert_anon" on public.vajicka_scores;
create policy "scores_insert_anon"
on public.vajicka_scores
for insert
to anon
with check (true);

-- Policy: deny direct select on base table for anon (protect email_hash)
drop policy if exists "scores_select_anon" on public.vajicka_scores;
create policy "scores_select_anon"
on public.vajicka_scores
for select
to anon
using (false);

-- Policy: allow anon to select from public view
-- (RLS is on the base table; for views, the underlying RLS still applies,
-- so we must expose select via a separate table/function OR keep selects
-- against the view routed through a SECURITY DEFINER function.)
--
-- Simplest approach: expose a SECURITY DEFINER function to fetch leaderboard.

create or replace function public.get_vajicka_leaderboard(limit_n int)
returns table (id uuid, nick text, eggs int, ms int, ts bigint)
language sql
security definer
set search_path = public
as $$
  select id, nick, eggs, ms, ts
  from public.vajicka_scores
  order by eggs desc, ms asc, ts desc
  limit greatest(1, least(limit_n, 1000));
$$;

create or replace function public.get_vajicka_stats(limit_n int)
returns table (plays bigint, unique_nicks bigint, avg_ms bigint)
language sql
security definer
set search_path = public
as $$
  with s as (
    select nick, ms
    from public.vajicka_scores
    order by created_at desc
    limit greatest(1, least(limit_n, 5000))
  )
  select
    count(*)::bigint as plays,
    count(distinct nick)::bigint as unique_nicks,
    coalesce(round(avg(ms))::bigint, null) as avg_ms
  from s;
$$;

grant execute on function public.get_vajicka_leaderboard(int) to anon;
grant execute on function public.get_vajicka_stats(int) to anon;

