<div align="center">

# 🎓 StudyMate AI

### Your AI-powered personal study companion

**Organize subjects · Upload notes · Learn with an AI tutor · Quiz yourself · Master flashcards · Build your streak**

Built with **React + Vite + Tailwind CSS**, **FastAPI**, **Supabase** (Postgres + pgvector + Auth + Storage), and **Google Gemini**.

[🌐 Live App](https://studymate-ai-learning.vercel.app) · [📚 API Docs](https://studymateai-backend-r3ul.onrender.com/docs) · [💚 API Health](https://studymateai-backend-r3ul.onrender.com/health)

</div>

---

## ✨ What it does

The complete learning loop, end-to-end:

> **Register → Create Subject → Upload Notes → Ask the Tutor → Generate Quizzes & Flashcards → Track Progress**

| | |
|---|---|
| ✅ **Auth** | Email/password with confirmation links, account recovery, protected routes — powered by Supabase Auth |
| 📚 **Subjects** | Create and organize colorful subject workspaces with documents, chats, quizzes & flashcards |
| 📄 **Notes** | Upload **PDF / TXT** (up to 50 MB) into private storage with live processing status |
| 🧠 **AI Tutor** | Gemini-powered tutor with **Markdown** answers, **source citations**, conversation history, and 4 teaching **personas** (Default, Feynman, Exam, Socratic) |
| 🔍 **RAG** | Retrieval-Augmented Generation: your questions are embedded and matched against your notes via **pgvector** cosine search |
| 🧪 **Quizzes** | AI-generated MCQs (subject- or document-grounded) with strict validation, server-side scoring, explanations & **weak-topic analytics** — plus **Practice weak topics** (AI quiz targeted at your lowest-accuracy topics) and **Redo as quiz** (rebuilds a quiz from your most-missed questions) |
| 🗂️ **Flashcards** | AI-generated flashcard decks with **SM-2 spaced repetition** (Again / Hard / Good / Easy) |
| 📊 **Progress** | Real study-time tracking (heartbeat sessions), dashboard stats, activity charts, quiz trends, a **GitHub-style study heatmap** with 🔥 **current/longest streaks**, and a **weekly study goal** with capsule-bar progress |
| 📖 **PDF reader** | In-app reader (**react-pdf**) side-by-side with the tutor on desktop and full-screen on mobile — source citations deep-link to the exact page; open any note in the tutor straight from Notes |
| 🔎 **Search** | Global quick-search across subjects, notes & quizzes (Ctrl/⌘+K) |
| 🌗 **Theme** | Light / Dark / System with a polished, responsive Core-style SaaS UI |

---

## 🛠️ Technology Stack

### Frontend — `frontend/`
| Tech | Purpose |
|---|---|
| [React 19](https://react.dev) + [TypeScript](https://www.typescriptlang.org) | UI & type safety |
| [Vite 8](https://vite.dev) | Build tool & dev server |
| [Tailwind CSS 4](https://tailwindcss.com) | Styling (utility-first, dark mode) |
| [React Router 7](https://reactrouter.com) | Client-side routing |
| [TanStack Query 5](https://tanstack.com/query) | Server-state & caching |
| [Axios](https://axios-http.com) | HTTP client (with upload progress) |
| [Lucide Icons](https://lucide.dev) | Icon set |
| [Recharts 3](https://recharts.org) | Activity & progress charts |
| [react-markdown](https://github.com/remarkjs/react-markdown) + [remark-gfm](https://github.com/remarkjs/remark-gfm) | Markdown tutor answers |
| [react-dropzone](https://react-dropzone.js.org) | Drag‑and‑drop file uploads |
| [react-pdf](https://wojtekmaj.github.io/react-pdf/) | In-app PDF reader (pdf.js worker, code-split chunk) |
| [@supabase/supabase-js](https://supabase.com/docs/reference/javascript) | Auth client |
| [Oxlint](https://oxc.rs) | Linting |

### Backend — `backend/`
| Tech | Purpose |
|---|---|
| [Python 3](https://www.python.org) + [FastAPI](https://fastapi.tiangolo.com) | REST API |
| [Uvicorn](https://www.uvicorn.org) | ASGI server |
| [Pydantic v2](https://docs.pydantic.dev) | Validation & settings |
| [Supabase Python SDK](https://supabase.com/docs/reference/python) | DB / Storage / RPC |
| [Google GenAI SDK](https://ai.google.dev/gemini-api/docs) | Gemini tutor, quizzes, flashcards & embeddings |
| [PyJWT](https://pyjwt.readthedocs.io) | Supabase access-token verification |
| [pypdf](https://pypi.org/project/pypdf/) | PDF text extraction |
| [httpx](https://www.python-httpx.org) | Groq fallback calls (OpenAI-compatible) |
| [pytest](https://docs.pytest.org) + pytest-asyncio | Tests |

### Data & Infrastructure
| Tech | Purpose |
|---|---|
| [Supabase Postgres](https://supabase.com) | Database with **Row-Level Security** |
| [pgvector](https://github.com/pgvector/pgvector) | `vector(768)` embeddings + **HNSW index** for similarity search |
| [Supabase Storage](https://supabase.com/docs/guides/storage) | Private `study-documents` bucket |
| [Supabase Auth](https://supabase.com/docs/guides/auth) | Email/password + JWT |
| [Google Gemini](https://ai.google.dev) | `gemini-3.8-flash` (text) + `gemini-embedding-2` (embeddings) |
| [Groq](https://groq.com) | **Fallback** LLM when Gemini is rate-limited |
| [Vercel](https://vercel.com) | Frontend hosting (auto-deploy from GitHub) |
| [Render](https://render.com) | Backend hosting (auto-deploy from GitHub) |

---

## 🏗️ Architecture

```text
┌──────────────────────────────┐          ┌──────────────────────────────────────┐
│        React Frontend        │          │            FastAPI Backend            │
│  (Vercel · SPA + vercel.json)│  HTTPS   │   (Render · uvicorn · /api)           │
│                              │ ───────► │                                      │
│  Pages     TanStack Query    │  Bearer  │  Routers ──► Services                 │
│  Auth      axios             │   JWT    │   subjects/docs/chats/quizzes/        │
│  Theme     Recharts          │          │   flashcards/progress/sessions        │
│  Reader    react-pdf         │          │                                      │
└──────┬───────────────────────┘          │        │        │        │ RAG        │
       │ email links / session           │        │        │        │             │
       ▼                                 ▼        ▼        ▼        ▼             │
┌─────────────────────────────────────────────────────────────────────────────────┐
│                             Supabase Cloud                                       │
│   Auth (email confirm/reset)        Postgres + pgvector + HNSW                   │
│   Storage (private bucket)          ── match_document_chunks() RPC               │
└─────────────────────────────────────────────────────────────────────────────────┘
        ▲ Gemini 3.8 Flash + Embeddings (server-side)   ▲ Groq fallback
        └──────────────────────────────────────────────┘
```

**How a tutor reply works**
1. Your message is saved and **embedded** (`gemini-embedding-2`, 768-d) in parallel.
2. `match_document_chunks()` searches only **your** chunks in the current subject (cosine, top‑k=5).
3. The top excerpts are injected as *untrusted reference material* into the system prompt.
4. `gemini-3.8-flash` (or Groq on rate-limit) produces the answer with source citations.
5. The reply + citations are persisted and rendered as Markdown.

---

## 📁 Repository layout

```text
Study-Mate/
├── frontend/            # React + Vite SPA       → github.com/zeeshanshaikh-dev/studymate-ai-frontend
│   ├── src/
│   │   ├── pages/       # Login, Dashboard, Subjects, Chat, Notes, Quizzes, Flashcards, Progress, Settings, …
│   │   ├── components/  # layout/, ui/, pdf/ (in-app reader), feature components
│   │   ├── services/    # typed API clients (subjects, chats, documents, quizzes, flashcards, progress, sessions)
│   │   ├── lib/         # axios + supabase clients
│   │   ├── contexts/    # AuthContext
│   │   ├── types/       # shared domain types
│   │   └── routes/      # ProtectedRoute / PublicOnlyRoute
│   ├── vercel.json      # SPA rewrite (client-side routes)
│   └── package.json
├── backend/             # FastAPI               → github.com/zeeshanshaikh-dev/studymateai-backend
│   └── app/
│       ├── api/         # subjects, documents, chats, quizzes, flashcards, progress, dashboard, study_sessions
│       ├── services/    # chat, documents, rag, quizzes, flashcards, progress, study_sessions, subjects, groq
│       ├── schemas/     # Pydantic models
│       ├── dependencies/# JWT auth
│       └── db/          # Supabase client
├── supabase/
│   └── migrations/      # 001_initial_schema · 002_weak_topics_flashcards_persona · 002_quiz_note_source
└── StudyMate_AI_PRD_v3.md  # The product spec
```

> **About this repository:** [`zeeshanshaikh-dev/StudyMate-AI`](https://github.com/zeeshanshaikh-dev/StudyMate-AI)
> hosts the project docs (`README.md`, `StudyMate_AI_PRD_v3.md`) and the Supabase schema.
> The application code lives in the `frontend/` and `backend/` repos linked above.

---

## 🚀 Getting started (local development)

### Prerequisites
- [Node.js](https://nodejs.org) 20+ and npm
- [Python](https://www.python.org) 3.11+
- A [Supabase](https://supabase.com) project (database, auth, storage)
- A [Google AI Studio](https://aistudio.google.com) API key (and optional [Groq](https://console.groq.com/keys) key as fallback)

### 1. Database
Run the three migration files in the Supabase **SQL Editor** (in order):
```text
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_weak_topics_flashcards_persona.sql
supabase/migrations/002_quiz_note_source.sql
```
Create the private bucket `study-documents` (the migration inserts it if it doesn’t exist).

### 2. Backend
```bash
cd backend
python -m venv .venv && .venv\Scripts\activate      # Windows
pip install -r requirements.txt
copy .env.example .env                              # then fill in real values
uvicorn app.main:app --reload --port 8000
```
→ API at http://localhost:8000 · interactive docs at http://localhost:8000/docs

### 3. Frontend
```bash
cd frontend
npm install
copy .env.example .env                              # then fill in real values
npm run dev
```
→ App at http://localhost:5173

`VITE_API_BASE_URL` can point to the local backend (`http://localhost:8000`) or the deployed one.

---

## 🔐 Environment variables

**`frontend/.env`** (safe to expose to the browser)
```env
VITE_SUPABASE_URL=
VITE_SUPABASE_PUBLISHABLE_KEY=
VITE_API_BASE_URL=http://localhost:8000
```

**`backend/.env`** (server-only — never commit)
```env
SUPABASE_URL=
SUPABASE_PUBLISHABLE_KEY=
SUPABASE_SECRET_KEY=
SUPABASE_JWT_SECRET=
GEMINI_API_KEY=
GEMINI_MODEL=gemini-3.8-flash
GEMINI_EMBEDDING_MODEL=gemini-embedding-2
GROQ_API_KEY=
GROQ_MODEL=groq/compound
CORS_ORIGINS=["http://localhost:5173","https://studymate-ai-learning.vercel.app"]
```

> **Production checklist:** on Render, set the backend env vars above. On Vercel, set the
> `VITE_*` vars. In the Supabase dashboard ensure **Site URL** and **Redirect URLs** point at
> the production domain so email confirmation/reset links work.

---

## 📡 API overview

| Group | Endpoints |
|---|---|
| Subjects | `GET/POST /api/subjects` · `GET/PATCH/DELETE /api/subjects/{id}` |
| Chats | `GET/POST /api/subjects/{sid}/chats` · `PATCH/DELETE /api/chats/{id}` |
| Messages | `GET /api/chats/{id}/messages` · `POST /api/chats/{id}/messages` |
| Documents | `GET/POST /api/subjects/{sid}/documents` · `GET/DELETE /api/documents/{id}` · `POST /api/documents/{id}/retry` |
| Quizzes | `POST /api/subjects/{sid}/quizzes/generate` *(optional `topics` to target weak spots)* · `POST .../quizzes/redo-missed` · `GET /api/quizzes` · `GET/POST /api/quizzes/{id}/attempts` |
| Flashcards | `GET /api/subjects/{sid}/flashcards` · `POST .../generate` · `GET /api/flashcards/due` · `POST /api/flashcards/{id}/review` |
| Progress | `GET /api/dashboard/summary` · `GET /api/progress` · `GET /api/progress/activity` *(heatmap + streaks)* · `GET /api/progress/weak-areas` · `GET /api/subjects/{sid}/progress` |
| Study sessions | `POST .../study-sessions/start` · `POST /api/study-sessions/{id}/heartbeat` · `POST .../end` |

Full details: `StudyMate_AI_PRD_v3.md` → §12.

---

## 🧪 Scripts

| Frontend | Backend |
|---|---|
| `npm run dev` — dev server | `uvicorn app.main:app --reload` — API |
| `npm run build` — typecheck + build | `pytest` — test suite (38 tests) |
| `npm run lint` — Oxlint | |

---

## 🌱 Roadmap ideas
- Streaming tutor responses (SSE)
- Bulk re-indexing when the embedding model changes
- Deeper spaced-repetition analytics
- Streak & goal insights (retention nudges built on the study heatmap)

---

<div align="center">

**Made with 💜 for students who love learning.**

</div>
