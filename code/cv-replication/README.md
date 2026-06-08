# cv-replication

Stata replication code for Study 1 (Aldy, Kotchen & Leiserowitz 2012) and
Study 2 (Giguere, Moore & Whitehead 2020).

**Contributor:** Trevor Woolley (trevor_woolley@berkeley.edu)

## Contents

```
do/         Stata .do scripts (see execution order below)
data/       intermediate/processed data used by do-files
figures/    figure output
```

## .do files (from Drive: Replication_and_Analysis_Code/do/)

Confirmed files present in Drive as of 2026-06-08:

**Study 1 (NCES / Aldy et al.)**
| File | Purpose |
|---|---|
| `1_make_data_Var1Var2.do` | Build working data for demographics-only and beliefs+demographics variants |
| `1_make_data_Var3.do` | Build working data for Var3 (one-belief condition) |
| `2_make_figs_Var1Var2.do` | Figures: approval curves by LLM, Study 1 |
| `2_make_figs_Var1Var2_panellvl.do` | WTP estimation + LaTeX tables (panel-level logit), Study 1 |
| `2_make_figs_Var3.do` | Figures for Var3 condition |

**Study 2 (Forest WTP / Giguere et al.)**
| File | Purpose |
|---|---|
| `1c_make_data_ForestWTP.do` | Build working data for Study 2 |
| `2b_logit_ForestWTP.do` | Logit estimation, Study 2 |
| `2b_make_figs_ForestWTP.do` | Figures + tables, Study 2 |

**Shared / other**
| File | Purpose |
|---|---|
| `Analysis_AK.do` | Alina's analysis script |
| `Paper_Replication_AK.do` | Alina's replication of paper logits |
| `Chunk_code_AK.do` | Alina's chunking code |

## Execution order (Study 1)

```stata
do do/1_make_data_Var1Var2.do
do do/2_make_figs_Var1Var2_panellvl.do   // WTP + tables
do do/2_make_figs_Var1Var2.do            // approval curve figures
```

**Stata version:** <!-- e.g. Stata 18 -->
**Required packages:** `wtpcikr`, `grc1leg2` (both via `ssc install`)

## Notes

Global paths in do-files currently point to Trevor's local machine
(`D:\Projects\LLM_CV\`). Update the three globals at the top of each script:

```stata
global datadir "YOUR_PATH/data"
global figdir  "YOUR_PATH/figures"
global tabdir  "YOUR_PATH/figures/tables"
```

Original human survey data from Aldy/Kotchen/Leiserowitz and
Giguere/Moore/Whitehead is **not** included per data-use agreements.
See `data/README.md` in the repo root.
