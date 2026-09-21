-- ============================================================
-- StudyMate AI — Database Migration v1
-- Run this in Supabase SQL Editor
-- ============================================================

-- Enable pgvector extension
create extension if not exists vector;

-- ============================================================
-- TABLE: profiles
-- ============================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- ============================================================
-- TABLE: subjects
-- ============================================================
create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) > 0),
  description text,
  color text default '#4F6EF7',
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

create index if not exists subjects_user_id_idx on public.subjects(user_id);

-- ============================================================
-- TABLE: conversations
-- ============================================================
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

create index if not exists conversations_subject_id_idx on public.conversations(subject_id);
create index if not exists conversations_user_id_idx on public.conversations(user_id);

-- ============================================================
-- TABLE: messages
-- ============================================================
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  content text not null,
  sources jsonb,
  created_at timestamptz default now() not null
);

create index if not exists messages_conversation_id_idx on public.messages(conversation_id);

-- ============================================================
-- TABLE: documents
-- ============================================================
create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  filename text not null,
  storage_path text not null,
  mime_type text not null,
  file_size_bytes bigint not null,
  processing_status text not null default 'pending'
    check (processing_status in ('pending', 'processing', 'completed', 'failed')),
  processing_error text,
  page_count integer,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

create index if not exists documents_subject_id_idx on public.documents(subject_id);
create index if not exists documents_user_id_idx on public.documents(user_id);

-- ============================================================
-- TABLE: document_chunks
-- ============================================================
create table if not exists public.document_chunks (
  id uuid primary key default gen_random_uuid(),
  document_id uuid not null references public.documents(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  chunk_index integer not null,
  chunk_text text not null,
  page_number integer,
  embedding vector(768) not null,
  created_at timestamptz default now() not null
);

create index if not exists document_chunks_subject_id_idx on public.document_chunks(subject_id);
create index if not exists document_chunks_user_id_idx on public.document_chunks(user_id);

-- HNSW index for cosine similarity search
create index if not exists document_chunks_embedding_hnsw_idx
  on public.document_chunks
  using hnsw (embedding vector_cosine_ops)
  with (m = 16, ef_construction = 64);

-- ============================================================
-- TABLE: quizzes
-- ============================================================
create table if not exists public.quizzes (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  difficulty text not null check (difficulty in ('easy', 'medium', 'hard')),
  question_count integer not null,
  source_type text not null check (source_type in ('subject', 'documents')),
  created_at timestamptz default now() not null
);

create index if not exists quizzes_subject_id_idx on public.quizzes(subject_id);
create index if not exists quizzes_user_id_idx on public.quizzes(user_id);

-- ============================================================
-- TABLE: quiz_questions
-- ============================================================
create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  question_text text not null,
  options jsonb not null,
  correct_answer text not null,
  explanation text not null,
  question_order integer not null
);

create index if not exists quiz_questions_quiz_id_idx on public.quiz_questions(quiz_id);

-- ============================================================
-- TABLE: quiz_attempts
-- ============================================================
create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  score integer not null default 0,
  total_questions integer not null,
  started_at timestamptz default now() not null,
  completed_at timestamptz
);

create index if not exists quiz_attempts_quiz_id_idx on public.quiz_attempts(quiz_id);
create index if not exists quiz_attempts_user_id_idx on public.quiz_attempts(user_id);

-- ============================================================
-- TABLE: quiz_answers
-- ============================================================
create table if not exists public.quiz_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.quiz_attempts(id) on delete cascade,
  question_id uuid not null references public.quiz_questions(id) on delete cascade,
  selected_answer text not null,
  is_correct boolean not null
);

create index if not exists quiz_answers_attempt_id_idx on public.quiz_answers(attempt_id);

-- ============================================================
-- TABLE: study_sessions
-- ============================================================
create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  started_at timestamptz default now() not null,
  ended_at timestamptz,
  duration_seconds integer default 0,
  last_heartbeat_at timestamptz default now() not null
);

create index if not exists study_sessions_user_id_idx on public.study_sessions(user_id);
create index if not exists study_sessions_subject_id_idx on public.study_sessions(subject_id);

-- ============================================================
-- FUNCTION: Auto-update updated_at
-- ============================================================
create or replace function public.handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger handle_updated_at before update on public.profiles
  for each row execute function public.handle_updated_at();
create trigger handle_updated_at before update on public.subjects
  for each row execute function public.handle_updated_at();
create trigger handle_updated_at before update on public.conversations
  for each row execute function public.handle_updated_at();
create trigger handle_updated_at before update on public.documents
  for each row execute function public.handle_updated_at();

-- ============================================================
-- FUNCTION: Auto-create profile on user signup
-- ============================================================
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- FUNCTION: match_document_chunks (RAG vector search RPC)
-- ============================================================
create or replace function public.match_document_chunks(
  query_embedding vector(768),
  match_count integer,
  p_user_id uuid,
  p_subject_id uuid,
  similarity_threshold float default 0.3
)
returns table (
  id uuid,
  document_id uuid,
  filename text,
  page_number integer,
  chunk_text text,
  similarity float
)
language plpgsql as $$
begin
  return query
  select
    dc.id,
    dc.document_id,
    d.filename,
    dc.page_number,
    dc.chunk_text,
    1 - (dc.embedding <=> query_embedding) as similarity
  from public.document_chunks dc
  join public.documents d on d.id = dc.document_id
  where dc.user_id = p_user_id
    and dc.subject_id = p_subject_id
    and d.processing_status = 'completed'
    and 1 - (dc.embedding <=> query_embedding) > similarity_threshold
  order by dc.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- profiles
alter table public.profiles enable row level security;
create policy "Users can view own profile" on public.profiles
  for select using (auth.uid() = id);
create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = id);

-- subjects
alter table public.subjects enable row level security;
create policy "Users can manage own subjects" on public.subjects
  for all using (auth.uid() = user_id);

-- conversations
alter table public.conversations enable row level security;
create policy "Users can manage own conversations" on public.conversations
  for all using (auth.uid() = user_id);

-- messages (accessible if parent conversation belongs to user)
alter table public.messages enable row level security;
create policy "Users can manage messages in own conversations" on public.messages
  for all using (
    exists (
      select 1 from public.conversations c
      where c.id = messages.conversation_id
        and c.user_id = auth.uid()
    )
  );

-- documents
alter table public.documents enable row level security;
create policy "Users can manage own documents" on public.documents
  for all using (auth.uid() = user_id);

-- document_chunks
alter table public.document_chunks enable row level security;
create policy "Users can manage own document chunks" on public.document_chunks
  for all using (auth.uid() = user_id);

-- quizzes
alter table public.quizzes enable row level security;
create policy "Users can manage own quizzes" on public.quizzes
  for all using (auth.uid() = user_id);

-- quiz_questions (accessible via quiz ownership)
alter table public.quiz_questions enable row level security;
create policy "Users can view questions of own quizzes" on public.quiz_questions
  for all using (
    exists (
      select 1 from public.quizzes q
      where q.id = quiz_questions.quiz_id
        and q.user_id = auth.uid()
    )
  );

-- quiz_attempts
alter table public.quiz_attempts enable row level security;
create policy "Users can manage own quiz attempts" on public.quiz_attempts
  for all using (auth.uid() = user_id);

-- quiz_answers
alter table public.quiz_answers enable row level security;
create policy "Users can manage own quiz answers" on public.quiz_answers
  for all using (
    exists (
      select 1 from public.quiz_attempts qa
      where qa.id = quiz_answers.attempt_id
        and qa.user_id = auth.uid()
    )
  );

-- study_sessions
alter table public.study_sessions enable row level security;
create policy "Users can manage own study sessions" on public.study_sessions
  for all using (auth.uid() = user_id);

-- ============================================================
-- STORAGE: study-documents bucket
-- (Create bucket manually in Supabase dashboard, then run:)
-- ============================================================
insert into storage.buckets (id, name, public)
values ('study-documents', 'study-documents', false)
on conflict (id) do nothing;

create policy "Users can upload their own documents" on storage.objects
  for insert with check (
    bucket_id = 'study-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can read their own documents" on storage.objects
  for select using (
    bucket_id = 'study-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can delete their own documents" on storage.objects
  for delete using (
    bucket_id = 'study-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
