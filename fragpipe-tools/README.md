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
- **FragPipe 24.0** — https://github.com/Nesvilab/FragPipe/releases (tag 24.0).
  On first launch it downloads MSFragger / IonQuant / Philosopher / diaTracer
  after you accept each license. Copy the resulting tools into the tree above.
- **DIA-NN 1.8.1** — https://github.com/vdemichev/DiaNN/releases.

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
