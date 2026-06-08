# Contributing to `synthetic-cv`

This document tells each contributor exactly where their files go.

## Repository map

```
synthetic-cv/
├── code/
│   ├── cv-replication/     ← Trevor: Stata replication code
│   ├── experiment-c/       ← Alina: Experiment C analysis scripts
│   └── experiment-e/       ← Alina: Experiment E analysis scripts
├── data/
│   ├── synthetic/          ← Kasra/sg: ISM-generated synthetic response panels
│   ├── experiment-c/       ← Alina: Experiment C data (redistributable only)
│   └── experiment-e/       ← Alina: Experiment E data (redistributable only)
├── alethic-ism/            ← git submodule → alethicresearch/alethic-ism
├── paper/                  ← Overleaf git subtree (sg manages)
├── results/
│   ├── figures/            ← publication-ready figures
│   └── tables/             ← publication-ready tables
└── web/                    ← alethic.ai/wtp landing page (sg/Kasra)
```

## Per-contributor instructions

### Trevor Woolley — `code/cv-replication/`

Deposit your `Replication_and_Analysis_Code` folder contents here:

```
code/cv-replication/
├── data/       ← intermediate/processed data used by do-files
├── do/         ← Stata .do scripts
└── figures/    ← figure output from do-files
```

Include a `README.md` describing script execution order and any dependencies
(Stata version, packages).

**Do not commit** original human survey data from Aldy/Kotchen/Leiserowitz or
Giguere/Moore/Whitehead — these are covered by data-use agreements.
See `data/README.md`.

---

### Alina Khindanova — `code/experiment-c/`, `code/experiment-e/`, `data/experiment-c/`, `data/experiment-e/`

Analysis scripts go under `code/experiment-c/` and `code/experiment-e/`.
Data files (only what is redistributable under your data-use agreements) go
under the corresponding `data/` subfolder.

Include a `README.md` in each code folder describing:
- what each script does
- execution order
- software and package dependencies (R / Python version, key packages)

**Do not commit** original survey data from either study without confirming
redistributability with the original authors.

---

### Kasra Rasaee — `data/synthetic/`, `alethic-ism/`

Synthetic response panels (per-respondent × per-model × per-condition) go in
`data/synthetic/`. Follow the naming convention already established there.

`alethic-ism/` is a git submodule pointing to
`https://github.com/alethicresearch/alethic-ism`. Do not add files directly
into this directory — update the submodule reference instead:

```bash
cd alethic-ism
git pull origin main
cd ..
git add alethic-ism
git commit -m "chore: update alethic-ism submodule"
```

---

### Sankalpa Ghose — `paper/`, `web/`, overall coordination

`paper/` is synced from Overleaf via git subtree:

```bash
git subtree pull --prefix=paper overleaf master --squash
git push origin main
```

`web/` contains the landing page source deployed at `alethic.ai/wtp`.

---

## General rules

- **Commit messages**: present tense, lowercase, short.
  e.g. `add study1 estimation script`, `update figure4 output`
- **Branch before large additions**: `git checkout -b alina/experiment-c`,
  push, open a PR for sg to merge.
- **No large binaries**: do not commit PDF outputs, `.RData` dumps, or model
  checkpoint files without checking with sg first.
- **Sensitive data**: when in doubt about redistributability, add the file to
  `.gitignore` and note it in the relevant `README.md`.

## Submodule setup (first clone)

```bash
git clone --recurse-submodules https://github.com/alethicresearch/synthetic-cv.git
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```
