-- ============================================================
-- StudyMate AI — Database Migration v2
-- Weak topics (quiz question topic tags), flashcards (spaced
-- repetition), and tutor personas.
-- Run this in Supabase SQL Editor (same workflow as migration 001).
-- ============================================================

-- ============================================================
-- quiz_questions: topic tag for weak-topic analytics
-- (nullable — questions generated before v2 have no tag)
-- ============================================================
alter table public.quiz_questions add column if not exists topic text;

create index if not exists quiz_questions_quiz_id_idx on public.quiz_questions(quiz_id);

-- ============================================================
-- conversations: tutor persona used for this chat
-- ============================================================
alter table public.conversations
  add column if not exists persona text not null default 'default';

alter table public.conversations
  drop constraint if exists conversations_persona_check;

alter table public.conversations
  add constraint conversations_persona_check
  check (persona in ('default', 'feynman', 'exam', 'socratic'));

-- ============================================================
-- TABLE: flashcards (spaced-repetition cards, SM-2 scheduling)
-- ============================================================
create table if not exists public.flashcards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  source_document_id uuid references public.documents(id) on delete set null,
  front text not null,
  back text not null,
  ease_factor double precision not null default 2.5,
  interval_days double precision not null default 0,
  repetitions integer not null default 0,
  due_at timestamptz not null default now(),
  last_reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists flashcards_user_id_idx on public.flashcards(user_id);
create index if not exists flashcards_subject_id_idx on public.flashcards(subject_id);
create index if not exists flashcards_due_idx on public.flashcards(user_id, due_at);

-- ============================================================
-- ROW LEVEL SECURITY: flashcards
-- ============================================================
alter table public.flashcards enable row level security;

create policy "Users can manage own flashcards" on public.flashcards
  for all using (auth.uid() = user_id);