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
Clone this repository, then enter the folder:
```bash
git clone https://github.com/Cheng77c/topdown-agent-deploy.git
cd topdown-agent-deploy
```
> The kit (compose + docs + CA cert) is public, but the **images themselves stay
> private** — you still need the username + password we gave you (step 3).
**All commands below assume you are inside this folder** — it contains `ca.crt`,
`docker-compose.yml` and `.env.example`. Verify:
```bash
ls ca.crt docker-compose.yml .env.example
```

## 2. Trust our registry's certificate
Our registry is `hgmz1471486.bohrium.tech:50001` and uses a **self-signed
certificate**, so Docker must be told to trust our `ca.crt` (shipped in this kit)
**once** before you can log in.

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

## 3. Log in to the registry
With the CA trusted, log in using the **username + password** we gave you (run
from inside the kit folder):
```bash
docker login hgmz1471486.bohrium.tech:50001
# Username: <the name we gave you>
# Password: <the password we gave you>
```
You should see **`Login Succeeded`**. If you instead get an `x509`/TLS error, the
CA trust in step 2 didn't take effect — redo it and **restart Docker Desktop**.

> This is the only login. The web app itself (step 5, http://localhost:3000) has
> **no login screen** — it opens straight into the workspace.

## 4. Configure
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

## 5. Pull and start
```bash
docker compose pull
docker compose up -d
```
Open **http://localhost:3000** (no login — straight into the app). The first
`pull` downloads several GB (the agent image bundles all analysis tools), so it
takes a while.

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

## Bottom-up tools (FragPipe / DIA-NN) — optional, bring-your-own
Top-down tools (TopFD / TopPIC / FLASHDeconv / …) are **bundled** and work out of
the box. The **bottom-up** suite (FragPipe + DIA-NN) is **not shipped** in the
image — those tools carry their own licenses that don't let us redistribute them.
A **guided setup** makes adding them easy: you only download **3 license-gated
tools** yourself; everything else ships with FragPipe and is arranged for you.

```bash
# 1. Start the setup helper (the official FragPipe GUI, on Linux)
docker compose --profile setup run --rm --service-ports tool-setup
#    -> open http://localhost:6080/vnc.html
#    In FragPipe -> Config: download MSFragger, IonQuant, diaTracer (accept each
#    academic license), save under /work.

# 2. Lay them out for the agent
docker compose --profile setup run --rm tool-setup arrange

# 3. Enable the mount: uncomment the bottom-up line under `agent` in
#    docker-compose.yml, then restart
docker compose up -d
```
The agent resolves tools **version-tolerantly**, so whatever versions FragPipe
gives you work. Full details + a manual alternative: `fragpipe-tools/README.md`.

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
