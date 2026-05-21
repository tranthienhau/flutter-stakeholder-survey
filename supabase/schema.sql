-- Supabase schema for stakeholder-survey POC.
-- Run in Supabase SQL editor.

create table if not exists surveys (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text default '',
  created_at timestamptz not null default now()
);

create table if not exists questions (
  id uuid primary key default gen_random_uuid(),
  survey_id uuid references surveys(id) on delete cascade,
  prompt text not null,
  type text not null check (type in ('shortText','longText','rating','singleChoice','multiChoice')),
  choices jsonb default '[]',
  order_index int default 0,
  required boolean default false
);

create table if not exists responses (
  id uuid primary key default gen_random_uuid(),
  survey_id uuid references surveys(id) on delete cascade,
  stakeholder_name text,
  stakeholder_role text,
  answers jsonb not null,
  submitted_at timestamptz not null default now()
);

create index if not exists responses_survey_submitted_idx
  on responses(survey_id, submitted_at desc);

-- Sample data
insert into surveys (id, title, description) values
  ('11111111-1111-1111-1111-111111111111', 'Product Discovery Interview',
   'Initial stakeholder interview to capture goals, pain points, and priorities.');

insert into questions (survey_id, prompt, type, choices, order_index, required) values
  ('11111111-1111-1111-1111-111111111111', 'What is your role on the project?', 'shortText', '[]', 1, true),
  ('11111111-1111-1111-1111-111111111111', 'Describe the biggest pain point you face today.', 'longText', '[]', 2, true),
  ('11111111-1111-1111-1111-111111111111', 'How urgent is solving this for your team?', 'rating', '[]', 3, true),
  ('11111111-1111-1111-1111-111111111111', 'Which channel do you prefer for updates?', 'singleChoice',
   '["Email","Slack","Phone","In-person"]', 4, false),
  ('11111111-1111-1111-1111-111111111111', 'Which features should we prioritise?', 'multiChoice',
   '["Reporting","Automation","Mobile access","Integrations","Custom roles"]', 5, false);
