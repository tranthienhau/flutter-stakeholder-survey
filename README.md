# flutter-stakeholder-survey

Flutter + Riverpod + Supabase POC for stakeholder interview / feedback collection with an admin progress dashboard.

## Features

- Browse a list of surveys (pulled from Supabase).
- Run a structured interview with mixed question types: short text, long text, rating, single choice, multi choice.
- Capture stakeholder name + role + answers as JSON.
- Admin dashboard: total responses, last 14 days, today, plus a bar chart of daily submissions per survey.
- Riverpod for state, GoRouter for navigation, fl_chart for stats.
- Deployable architecture: Flutter client + Supabase (Postgres) + Vercel (admin / web).

## Architecture

```
[Flutter app] --REST/Realtime--> [Supabase Postgres]
                                       ^
                                       |
                              [Vercel admin / web]
```

## Setup

1. Create a Supabase project, open the SQL editor, paste `supabase/schema.sql` and run it.
2. Copy the project URL + anon key.
3. Run the app with:

```
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR-ANON-KEY
```

## Tech

- Flutter 3.x, Dart 3.x
- Riverpod 2.x
- Supabase Flutter 2.x
- fl_chart, go_router, uuid, intl
