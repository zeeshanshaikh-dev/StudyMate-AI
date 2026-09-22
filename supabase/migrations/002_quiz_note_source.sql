-- ============================================================
-- 002: Quiz note source
-- Quizzes can now be generated from a single uploaded note.
-- document_id is nullable (subject/all-notes quizzes leave it null).
-- ============================================================

alter table public.quizzes
  add column if not exists document_id uuid
  references public.documents(id) on delete set null;

create index if not exists quizzes_document_id_idx on public.quizzes(document_id);