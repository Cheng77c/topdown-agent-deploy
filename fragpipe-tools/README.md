# Bottom-up tools (FragPipe / DIA-NN) — setup

This folder ends up holding the bottom-up tools, mounted into the container at
`/opt/fragpipe-tools`. **The recommended way to populate it is the guided
tool-setup below** — you only have to download **3 license-gated tools** yourself;
everything else ships with FragPipe and is laid out automatically.

## Recommended: guided setup (FragPipe in your browser)

```bash
# 1. Start the setup helper (runs the official FragPipe GUI on Linux)
docker compose --profile setup run --rm --service-ports tool-setup
```
Then open **http://localhost:6080/vnc.html** in your browser. You'll see FragPipe.

```
2. In FragPipe -> Config tab, click Download/Update for:
      • MSFragger
      • IonQuant
      • diaTracer
   Accept each academic license yourself. When asked where to save, save under /work.
   (Philosopher, DIA-NN, Percolator, DIA-Umpire, TMT-Integrator, MSBooster,
    PTM-Shepherd, Crystal-C … all ship with FragPipe — no download needed.)
```

```bash
# 3. Lay everything out for the agent
docker compose --profile setup run --rm tool-setup arrange

# 4. Enable the mount: uncomment the bottom-up line under `agent` in
#    docker-compose.yml, then restart
docker compose up -d
```

Because the agent resolves tools **version-tolerantly**, whatever versions FragPipe
gives you will work — you don't have to match exact version numbers.

## Licenses — read before using commercially
MSFragger, IonQuant and diaTracer are **free for academic/non-commercial use
only**; commercial use needs paid licenses (via Fragmatics). DIA-NN likewise
(Aptila/Thermo). You accept these yourself in FragPipe — they are **not** shipped
in the image.

## Manual alternative
If you'd rather assemble by hand, drop the tools into this folder so that the
agent finds (any version of) each of:
`msfragger/MSFragger-*.jar`, `ionquant/IonQuant-*.jar`, `philosopher/philosopher`,
`percolator/percolator`, `diann/diann-*`, `diatracer/diaTracer-*.jar`,
`dia-umpire/DIA_Umpire_SE-*.jar`, `tmt-integrator/TMT-Integrator-*.jar`,
`crystal-c/crystalc-*.jar` + `grppr-*.jar`, `ptmprophet/PTMProphetParser`,
`opair/CMD.dll`, `glycan-databases/*.txt`, and a full `fragpipe-24.0/` install.
