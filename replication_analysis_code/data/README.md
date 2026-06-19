# Data

**Primary archive (citable, permanent):** the 21 files needed to run this
replication code — raw inputs, analysis-ready Stata files, and summary
outputs — are archived on Zenodo:
[https://doi.org/10.5281/zenodo.20754919](https://doi.org/10.5281/zenodo.20754919).

**Full working file set (Google Drive):** the complete set of files,
including large intermediate/working datasets not included in the Zenodo
archive, remains available at
https://drive.google.com/drive/folders/1oTmV9N5PLXAQY6P8WeIX6znzgbLpp9FQ.

Download from whichever source you need and place the files in this
directory before running the `.do` scripts. The `raw/` subfolder contains a
small auxiliary file that is tracked in git.

---

## Directory Structure

Files marked **(Z)** are in the Zenodo archive. Files marked **(D)** are Drive-only
(intermediate/working outputs regenerable from the Zenodo files via the `.do` scripts).

```
data/
├── raw/                                  # Raw inputs (partially tracked in git)
│   ├── experiment_wtp_c_2025OCT20_montecarlo_cleaned.csv   # (Z) Monte Carlo output (~5.8 GB)
│   ├── 1. R01 - Variant 1 & 2 - ...Aggregates.xlsx         # Provider accuracy aggregates (git-tracked)
│   └── Experiment2/
│       ├── original_data.csv                               # (Z) Study 2 raw survey responses
│       ├── wtp_e_cleaned-v118.dta                          # (Z) Cleaned WTP experiment data (~685 MB)
│       ├── wtp_e_cleaned-v118-stata.dta.gz                 # (Z) Compressed version (~54 MB)
│       ├── wtp_e_cleaned.csv.gz                            # (D) Compressed CSV version (~222 MB)
│       └── wtp_e_cleaned/
│           └── wtp_e_cleaned.csv                           # (D) Uncompressed CSV (~7.8 GB)
│
├── working_data.dta                      # (D) Main merged working dataset (~512 MB)
├── working_data_var3.dta                 # (D) Variant 3 working dataset (~3.2 GB)
├── working_data_ForestWTP.dta            # (D) Forest WTP working dataset (~44 MB)
├── final_part.dta                        # (Z) Final analysis dataset (~495 MB)
├── Indiv_beliefs_data.dta                # (Z) Individual-level beliefs dataset (~3.2 GB)
├── wtp_e_working4loop.dta                # (D) WTP experiment data for estimation loop (~690 MB)
├── wtp_e_working4loop_v2.dta             # (D) Version 2 of above (~952 MB)
│
├── data_merge.dta                        # (Z) Merge diagnostics / crosswalk
├── provider_id_xwalk.dta                 # (Z) Provider ID crosswalk table
│
├── actual_vote_ForestWTP.dta             # (Z) Actual referendum vote data (Forest WTP)
├── actual_qsa.dta                        # (Z) Actual QSA vote data
│
├── empirical_bid_coefs_Study2.dta        # (Z) Empirical bid coefficients, Study 2
├── slope_ratios_Study1.dta               # (Z) Slope ratios from Study 1
├── slope_ratios_Study2.dta               # (Z) Slope ratios from Study 2
│
├── synth_beliefs.dta                     # (D) Synthetic beliefs dataset (pooled)
├── synth_beliefs_byProvider.dta          # (Z) Synthetic beliefs, by provider
├── synth_beliefQ_byProvider_Var3.dta     # (D) Synthetic belief questions, by provider (Variant 3)
├── synth_byProvider_ForestWTP.dta        # (Z) Synthetic data by provider (Forest WTP)
├── synth_demonly.dta                     # (D) Synthetic demographics-only dataset (pooled)
├── synth_demonly_byProvider.dta          # (Z) Synthetic demographics-only, by provider
│
├── wtp_all_Study2_long.dta               # (D) All WTP estimates, Study 2 (long format)
├── wtp_summary_withBeliefs_ForestWTP.dta # (Z) WTP summary with beliefs (Forest WTP)
├── wtp_summary_withoutBeliefs_ForestWTP.dta  # (Z) WTP summary without beliefs (Forest WTP)
├── wtp_summary_beliefs.dta               # (Z) WTP summary: beliefs specification
├── wtp_summary_qsa.dta                   # (Z) WTP summary: QSA specification
├── wtp_summary_actual.dta                # (Z) WTP summary: actual vote specification
│
├── wtp_prov{0–8}_withBeliefs_ForestWTP.dta    # (D) Per-provider WTP with beliefs (9 files)
└── wtp_prov{0–8}_withoutBeliefs_ForestWTP.dta # (D) Per-provider WTP without beliefs (9 files)
```

---

## File Descriptions

### Core Working Datasets

| File | Description | Size | Zenodo |
|------|-------------|------|--------|
| `working_data.dta` | Primary merged dataset used across analysis scripts | ~512 MB | — |
| `working_data_var3.dta` | Variant 3 specification of the working dataset | ~3.2 GB | — |
| `working_data_ForestWTP.dta` | Working dataset scoped to the Forest WTP analysis | ~44 MB | — |
| `final_part.dta` | Final cleaned dataset used for main results | ~495 MB | ✓ |
| `Indiv_beliefs_data.dta` | Individual-level elicited beliefs, full sample | ~3.2 GB | ✓ |
| `wtp_e_working4loop.dta` | WTP experiment data formatted for the estimation loop | ~690 MB | — |
| `wtp_e_working4loop_v2.dta` | Updated version of the estimation-loop dataset | ~952 MB | — |

### Raw Inputs (`raw/`)

| File | Description | Size | Zenodo |
|------|-------------|------|--------|
| `experiment_wtp_c_2025OCT20_montecarlo_cleaned.csv` | Cleaned Monte Carlo simulation output from the WTP experiment (Oct 2025 run) | ~5.8 GB | ✓ |
| `1. R01 - Variant 1 & 2 - ...Aggregates.xlsx` | Provider × question-type accuracy aggregates; **tracked in git** | ~18 KB | — |
| `Experiment2/original_data.csv` | Raw survey responses from Study 2 | ~189 KB | ✓ |
| `Experiment2/wtp_e_cleaned-v118.dta` | Cleaned Study 2 WTP experiment data, version 118 | ~685 MB | ✓ |
| `Experiment2/wtp_e_cleaned-v118-stata.dta.gz` | Gzip-compressed version of `wtp_e_cleaned-v118.dta` | ~54 MB | ✓ |
| `Experiment2/wtp_e_cleaned.csv.gz` | Gzip-compressed CSV version of the cleaned experiment data | ~222 MB | — |
| `Experiment2/wtp_e_cleaned/wtp_e_cleaned.csv` | Uncompressed CSV of the full cleaned experiment dataset | ~7.8 GB | — |

### Auxiliary / Crosswalk Files

| File | Description | Zenodo |
|------|-------------|--------|
| `data_merge.dta` | Merge diagnostics and key crosswalks used during dataset construction | ✓ |
| `provider_id_xwalk.dta` | Maps provider identifiers across datasets | ✓ |

### Referendum / Vote Data

| File | Description | Zenodo |
|------|-------------|--------|
| `actual_vote_ForestWTP.dta` | Observed referendum vote outcomes used in the Forest WTP analysis | ✓ |
| `actual_qsa.dta` | Observed QSA (quasi-social-acceptability) vote outcomes | ✓ |

### Estimation Inputs

| File | Description | Zenodo |
|------|-------------|--------|
| `empirical_bid_coefs_Study2.dta` | Empirical bid function coefficients from Study 2 | ✓ |
| `slope_ratios_Study1.dta` | Estimated slope ratios from Study 1 | ✓ |
| `slope_ratios_Study2.dta` | Estimated slope ratios from Study 2 | ✓ |

### Synthetic / Simulated Data

| File | Description | Zenodo |
|------|-------------|--------|
| `synth_beliefs.dta` | Synthetic beliefs data (pooled) | — |
| `synth_beliefs_byProvider.dta` | Synthetic beliefs, disaggregated by LLM provider | ✓ |
| `synth_beliefQ_byProvider_Var3.dta` | Synthetic belief question responses by provider, Variant 3 | — |
| `synth_byProvider_ForestWTP.dta` | Synthetic Forest WTP data by provider | ✓ |
| `synth_demonly.dta` | Synthetic data using demographics only (no beliefs), pooled | — |
| `synth_demonly_byProvider.dta` | Demographics-only synthetic data by provider | ✓ |

### WTP Summary and Provider-Level Estimates

These files contain willingness-to-pay estimates from mixed logit / Forest WTP models, summarized across or by LLM provider (providers indexed 0–8). Two specifications are estimated: **with beliefs** (beliefs + demographics conditioning) and **without beliefs** (demographics only).

| File Pattern | Description | Zenodo |
|---|---|---|
| `wtp_all_Study2_long.dta` | All WTP estimates from Study 2 in long format | — |
| `wtp_summary_withBeliefs_ForestWTP.dta` | Pooled WTP summary, with-beliefs spec (Forest WTP) | ✓ |
| `wtp_summary_withoutBeliefs_ForestWTP.dta` | Pooled WTP summary, without-beliefs spec (Forest WTP) | ✓ |
| `wtp_summary_beliefs.dta` | WTP summary under the beliefs specification | ✓ |
| `wtp_summary_qsa.dta` | WTP summary under the QSA specification | ✓ |
| `wtp_summary_actual.dta` | WTP summary under the actual-vote specification | ✓ |
| `wtp_prov{N}_withBeliefs_ForestWTP.dta` | Provider-specific WTP, with-beliefs (N = 0–8) | — |
| `wtp_prov{N}_withoutBeliefs_ForestWTP.dta` | Provider-specific WTP, without-beliefs (N = 0–8) | — |

---

## Notes

- All `.dta` files are Stata format. Use Stata 15+ or the `haven` R package / `pandas` with `pyreadstat` to read them.
- The large files (`working_data_var3.dta`, `Indiv_beliefs_data.dta`, `wtp_e_working4loop*.dta`) may require significant RAM (16–32 GB recommended for the largest files).
- Compressed `.gz` files in `raw/Experiment2/` can be decompressed with `gunzip` before loading into Stata.
- The `raw/` subfolder's `.xlsx` aggregate file is the only file tracked directly in git.
- Drive-only files marked **(D)** are intermediate outputs that can be regenerated by running the `.do` scripts against the Zenodo files.
