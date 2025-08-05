# Supabase HighScores Setup

This document describes how to create and secure the remote `high_scores` table used for saving user scores (>= 11) separately from the local SQFLite database.

## Prerequisites

- Supabase project created
- Supabase URL and anon key configured in [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart:1)
- Supabase Flutter initialized via [`lib/services/supabase_service.dart`](lib/services/supabase_service.dart:12)

## SQL Schema and Policies

Run the following SQL in the Supabase SQL editor:

```sql
BEGIN;

create table if not exists public.high_scores (
  id uuid primary key default gen_random_uuid(),
  username text not null,
  score int4 not null,
  recorded_at timestamptz not null default now(),
  constraint high_scores_score_min check (score >= 11)
);

-- Helpful indexes for leaderboard queries
create index if not exists idx_high_scores_score_desc on public.high_scores (score desc, recorded_at desc);
create index if not exists idx_high_scores_username on public.high_scores (username);

-- Enable RLS
alter table public.high_scores enable row level security;

-- Read policy: allow anyone to read (public leaderboard)
do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'high_scores' and policyname = 'Allow read to all'
  ) then
    create policy "Allow read to all"
      on public.high_scores
      for select
      using (true);
  end if;
end$$;

-- Insert policy: allow anyone to insert with score >= 11
do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'high_scores' and policyname = 'Allow insert to all with score >= 11'
  ) then
    create policy "Allow insert to all with score >= 11"
      on public.high_scores
      for insert
      with check (score >= 11);
  end if;
end$$;

-- No update/delete policies => effectively denied
COMMIT;
```

## Username Rules

- If a user is authenticated through Supabase, we read `user.userMetadata['display_name']`.
- If not authenticated or no display name is present, we save as `"Anon"`.

## App Integration

Code insertion points:

- Insert service: [`lib/services/high_scores_service.dart`](lib/services/high_scores_service.dart:1)
- Triggered automatically from results screen: [`lib/screens/results_review_screen.dart`](lib/screens/results_review_screen.dart:48)

Behavior:

- On game completion, if `finalScore >= 11`, a non-blocking call inserts `{ username, score, recorded_at }` to `public.high_scores`.
- Failures are silent and logged in debug builds.

## Optional Queries Implemented

Provided by [`HighScoresService.fetchTopScoreToday()`](lib/services/high_scores_service.dart:118) and [`HighScoresService.fetchTopScoreThisMonth()`](lib/services/high_scores_service.dart:146):

- fetchTopScoreToday: the single highest score recorded since UTC start-of-day
- fetchTopScoreThisMonth: the top 3 scores recorded since UTC start-of-month

Note on time zones: All comparisons use UTC boundaries to match the `timestamptz` semantics and server defaults.

## Validation

- Try a test insert from your app with a score of 11+ and confirm it appears in the public table editor.
- Verify that scores < 11 are rejected by DB due to the CHECK and RLS policies.
