-- Runs once on first cluster init (official postgres image entrypoint).
-- Creates the two databases the stack needs; both apps self-create their own
-- tables on startup, so no schema files are required here:
--   * langgraph  — LangGraph Agent Server (DATABASE_URI). The server runs its
--                  own migrations automatically.
--   * viewer_td  — viewer-TD / TDEase (DATABASE_URL). app.main lifespan calls
--                  ensure_jobs_table / ensure_*_schema (CREATE TABLE IF NOT EXISTS).
-- The default 'postgres' role + password come from POSTGRES_PASSWORD (image env).
CREATE DATABASE langgraph;
CREATE DATABASE viewer_td;
