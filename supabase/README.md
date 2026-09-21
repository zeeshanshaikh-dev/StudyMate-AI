# StudyMate AI · Supabase

Database, auth, storage, and vector search for StudyMate AI — all in one Supabase project
(PostgreSQL + pgvector + Auth + Storage).

## Migrations

Run these in the Supabase **SQL Editor**, in order, for a new project:

| File | Adds |
|---|---|
| [`001_initial_schema.sql`](migrations/001_initial_schema.sql) | Core tables (profiles, subjects, conversations, messages, documents, document_chunks, quizzes, quiz_questions, quiz_attempts, quiz_answers, study_sessions), pgvector extension, HNSW index, `match_document_chunks` RPC, updated_at/new-user triggers, RLS policies, storage bucket `study-documents` + policies |
| [`002_weak_topics_flashcards_persona.sql`](migrations/002_weak_topics_flashcards_persona.sql) | `quiz_questions.topic` (weak-topic analytics), `conversations.persona` (tutor personas), `flashcards` table (SM-2 spaced repetition) + RLS |

## What it configures

- **pgvector** — `document_chunks.embedding vector(768)` with an HNSW cosine index
  (`m=16, ef_construction=64`).
- **Vector search RPC** — `match_document_chunks(query_embedding, match_count, p_user_id, p_subject_id, similarity_threshold)` returns chunks with filename, page, text, and similarity — enforced to a single user/subject.
- **Row-Level Security** — enabled on every user-owned table; storage objects are scoped to the
  `{user_id}/…` folder prefix.
- **Triggers** — `updated_at` maintenance and automatic `profiles` creation on signup
  (`handle_new_user`, reading `display_name` from user metadata).

## Manual dashboard steps

1. **Authentication → URL Configuration**
   - Site URL: production frontend (e.g. `https://studymate-ai-learning.vercel.app`)
   - Redirect URLs: production origin (e.g. `https://studymate-ai-learning.vercel.app/**`) + localhost dev origins
2. **Authentication → Email Templates** — confirm signup / reset password use `{{ .ConfirmationURL }}`.
3. **Storage** — confirm the private bucket `study-documents` exists.
4. Generate **publishable (anon)** key for the frontend and **secret** key for the backend
   (both available in Project Settings → API), plus the **JWT secret** for backend token verification.