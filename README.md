# TopDown Agent — Deployment Guide

A self-hosted proteomics analysis agent. Runs as a small set of Docker
containers; everything is pulled from a private registry.

## Requirements
- **Docker Desktop** (Windows/Mac) or Docker Engine (Linux). Allocate ≥8 GB RAM.
- The registry credentials we provided (a **username + password**) and our
  **`ca.crt`** (bundled in this kit).
- An LLM API key (DeepSeek by default).

> The agent images are **linux/amd64**. On Apple Silicon Macs, enable Docker
> Desktop → Settings → General → **Use Rosetta for x86/amd64 emulation**.

## 1. Get the kit
Clone this repository (we've granted your GitHub account read access), or unzip
the kit archive we sent you, then enter the folder:
```bash
git clone https://github.com/Cheng77c/topdown-agent-deploy.git
cd topdown-agent-deploy
```
**All commands below assume you are inside this folder** — it contains `ca.crt`,
`docker-compose.yml` and `.env.example`. Verify:
```bash
ls ca.crt docker-compose.yml .env.example
```

## 2. Trust our registry, then log in
Our registry is `hgmz1471486.bohrium.tech:50001` and uses a **self-signed
certificate**, so Docker must be told to trust our `ca.crt` (shipped in this kit)
**once** before logging in.

**Linux (Docker Engine):**
```bash
sudo mkdir -p "/etc/docker/certs.d/hgmz1471486.bohrium.tech:50001"
sudo cp ca.crt "/etc/docker/certs.d/hgmz1471486.bohrium.tech:50001/ca.crt"
```

**macOS (Docker Desktop):** add the CA to the system keychain, then restart Docker
Desktop:
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
```

**Windows (Docker Desktop):** import `ca.crt` into **Trusted Root Certification
Authorities** (Run → `certlm.msc` → Trusted Root → Import), then restart Docker
Desktop.

Then log in (run from inside the kit folder):
```bash
docker login hgmz1471486.bohrium.tech:50001     # username + password we gave you
```

## 3. Configure
```bash
cp .env.example .env
```
Edit `.env` and set:
- `REGISTRY` — already set to `hgmz1471486.bohrium.tech:50001` (our registry)
- `LLM_API_KEY` — your LLM key
- `WORKSPACES_DIR` — a host folder that **contains your `.mzML`/`.raw` data**
  (recommended). See *Your data* below. Defaults to `./workspaces` if unset.

Everything else has working defaults. **Keep the ports** (50001/3000/7390) — the
UI has the backend address baked in.

## Your data (workspaces)

Set `WORKSPACES_DIR` in `.env` to one host folder that holds your input files,
e.g. `WORKSPACES_DIR=/Users/me/proteomics`. That folder is mounted into the app,
and **inside the web UI you pick a sub-folder of it as the workspace** for each
conversation. The agent reads your inputs from there and writes results back into
the same workspace (under a `jobs/<id>/` sub-folder per run), so products show up
right next to your data — for **any** task (top-down, bottom-up, auto-search).

- Multiple conversations can share one workspace safely — each run gets its own
  `jobs/<id>/` directory, so outputs never collide.
- Point `WORKSPACES_DIR` at the **common parent** of your datasets. If your data
  is scattered, mount the parent that holds them all (or consolidate under one).
- Use an **absolute path** on macOS/Windows.
- **Performance note:** on macOS/Windows, Docker Desktop reads host folders through
  a VM translation layer, so heavy read/write is slower than on Linux. For large
  campaigns, prefer a Linux host.

## 4. Pull and start
```bash
docker compose pull
docker compose up -d
```
Open **http://localhost:3000**. The first `pull` downloads several GB (the agent
image bundles all analysis tools), so it takes a while.

## Day-to-day
```bash
docker compose ps                 # status
docker compose logs -f agent      # logs
docker compose down               # stop (keeps data)
docker compose pull && docker compose up -d   # update to a newer release
```

## Data & persistence
Two kinds of storage:
- **Your data** — the host folder you set as `WORKSPACES_DIR` (inputs + analysis
  products + visualization bundles). It lives on your own disk; you can open it in
  Finder/Explorer. `down -v` does **not** touch it.
- **Internal state** — Docker named volumes `agent-state` (job database),
  `pg-data` (visualization DB) and `viewer-data` (derived visualization data).
  These survive `down`/restart. `docker compose down -v` wipes them (your
  `WORKSPACES_DIR` data is kept).

## Bring-your-own bottom-up tools (optional)
The top-down tools are bundled. The bottom-up suite (FragPipe / DIA-NN) is only
included if your release was built with them; otherwise contact us.

## Troubleshooting
- **`docker login` fails with a TLS/x509 error** — the `ca.crt` trust step (§1)
  wasn't applied, or Docker Desktop wasn't restarted afterward. Re-do §1.
- **`docker login` fails with unauthorized** — wrong username/password, or your
  account was removed; contact us.
- **Pull is slow** — first pull is several GB; subsequent updates are deltas.
- **Apple Silicon, tools fail** — the Windows-based converters (msconvert) run
  under emulation and can be flaky; prefer Windows/Intel for those steps, or feed
  `.mzML` directly.
- Anything else — send us `docker compose logs agent` and `docker compose logs viewer-td`.
