# Drop your bottom-up tools here

This folder is mounted into the container at **`/opt/fragpipe-tools`** (read-only)
when you enable the bottom-up mount. Put the downloaded tools here in **exactly**
this layout (versions matter):

```
fragpipe-tools/
├── fragpipe-24.0/
│   ├── lib/fragpipe-24.0.jar
│   └── tools/                # MSBooster-1.4.14.jar, ptmshepherd-3.0.11.jar,
│                             # batmass-io-1.36.5.jar, unimod.obo,
│                             # diann/1.8.2_beta_8/linux/diann-1.8.1.8
├── msfragger/MSFragger-4.4.jar        (+ ext/thermo)
├── ionquant/IonQuant-1.11.20.jar
├── philosopher/philosopher
├── percolator/percolator
├── crystal-c/{crystalc-1.5.0.jar, grppr-0.3.23.jar}
├── ptmprophet/PTMProphetParser
├── diann/diann-1.8.1.8
├── dia-umpire/DIA_Umpire_SE-2.3.4.jar
├── diatracer/{diaTracer-2.2.1.jar, ext/bruker}
├── tmt-integrator/TMT-Integrator-6.2.1.jar
├── glycan-databases/{glycan_residues.txt, glycan_mods.txt}
└── opair/CMD.dll
```

## Where to download
Use **these exact versions** — the agent expects FragPipe **24.0** and DIA-NN
**1.8.1**. Do NOT grab "latest"; newer versions change filenames/parameters and
won't resolve. The tools run inside a **Linux** container, so get the **Linux**
builds.

**Direct downloads (click to start):**
- FragPipe 24.0 (Linux): https://github.com/Nesvilab/FragPipe/releases/download/24.0/FragPipe-24.0-linux.zip
- DIA-NN 1.8.1 (Linux): https://github.com/vdemichev/DiaNN/releases/download/1.8.1/diann_1.8.1.tar.gz

**No direct link — license-gated (you must accept the academic license):**
MSFragger 4.4, IonQuant 1.11.20 and diaTracer 2.2.1 cannot be linked directly.
Unzip FragPipe 24.0, open its **Config** tab, and download these there — you accept
each tool's academic license, then FragPipe fetches them into its `tools` folder.
Copy the results into the tree above. (Philosopher comes the same way and must be
the **Linux** build.)

> Easiest path if assembling this is too fiddly: ask us for a pre-arranged Linux
> bundle (shared only where the license permits).

## Licenses — read before using commercially
MSFragger, IonQuant, diaTracer and DIA-NN are **free for academic/non-commercial
use only**. Commercial use needs paid licenses (MSFragger/IonQuant/diaTracer via
Fragmatics; DIA-NN via Aptila/Thermo). You download and accept these yourself —
they are **not** shipped in the image.

## Turn it on
1. Place the files above into this folder.
2. In `docker-compose.yml`, under the `agent` service, **uncomment**:
   `# - ${FRAGPIPE_TOOLS_DIR:-./fragpipe-tools}:/opt/fragpipe-tools:ro`
3. `docker compose up -d`
