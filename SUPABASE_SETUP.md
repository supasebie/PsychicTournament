# Supabase Setup Guide

This guide will help you set up Supabase authentication for the Psychic Tournament app.

## Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. Flutter development environment set up

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization
4. Enter a project name (e.g., "psychic-tournament")
5. Enter a database password (save this securely)
6. Select a region close to your users
7. Click "Create new project"

## Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to Settings > API
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **Anon public key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

## Step 3: Configure the App

1. Open `lib/config/supabase_config.dart`
2. Replace the placeholder values:
   ```dart
   static const String supabaseUrl = 'https://your-project-id.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key-here';
   ```

## Step 4: Set Up Authentication

The app is already configured to use email/password authentication. No additional setup is required in Supabase for basic auth.

### Optional: Email Templates

To customize the email templates for password reset and email confirmation:

1. Go to Authentication > Settings in your Supabase dashboard
2. Scroll down to "Email Templates"
3. Customize the templates as needed

### Optional: Social Authentication

To add social login providers (Google, GitHub, etc.):

1. Go to Authentication > Settings in your Supabase dashboard
2. Scroll down to "Auth Providers"
3. Enable and configure the providers you want to use
4. Update the app code to include social login buttons

## Step 5: Test the Integration

1. Run `flutter pub get` to install dependencies
2. Run the app with `flutter run`
3. Try creating a new account and signing in
4. Check the Authentication > Users section in your Supabase dashboard to see registered users

## Database Schema (Optional)

If you want to store user scores and game history, you can create additional tables:

```sql
-- Create a profiles table
create table profiles (
  id uuid references auth.users on delete cascade,
  display_name text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (id)
);

-- Create a game_scores table
create table game_scores (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade,
  score integer not null,
  total_cards integer not null default 25,
  game_type text not null default 'zener',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security
alter table profiles enable row level security;
alter table game_scores enable row level security;

-- Create policies
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);

create policy "Users can view own scores" on game_scores for select using (auth.uid() = user_id);
create policy "Users can insert own scores" on game_scores for insert with check (auth.uid() = user_id);
```

## Troubleshooting

### Common Issues

1. **"Invalid API key" error**: Double-check that you copied the anon key correctly
2. **"Invalid URL" error**: Make sure the URL includes `https://` and ends with `.supabase.co`
3. **Email not sending**: Check your email provider settings in Supabase dashboard

### Getting Help

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Supabase Community Discord](https://discord.supabase.com)
