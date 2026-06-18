# LLM for Contingent Valuation — Replication and Analysis Code


This repository contains all Stata code and output figures needed to replicate the analysis. The large datasets are hosted externally on Google Drive (see [`data/README`](#data) below).

---

## Project Overview

This project evaluates whether LLMs can serve as synthetic survey respondents in contingent valuation (CV) studies — specifically, willingness-to-pay (WTP) surveys for environmental goods. The analysis spans two main settings:

- **Study 1 / Variants 1 & 2 (QSA):** A quasi-social-acceptability framing, where simulated respondents are asked whether they would support a policy costing a given bid amount. LLM responses are compared against actual survey data under two conditioning variants: *demographics only* and *beliefs + demographics*.
- **Study 2 / Forest WTP:** A forest conservation contingent valuation study from a real survey (Great Smoky Mountains / Pisgah National Forest area). LLMs simulate respondents under a bounded or repeated bidding design, and synthetic WTP estimates are benchmarked against actual referendum votes and mixed-logit WTP estimates from the real survey.

The core research question: **do LLM-generated synthetic respondents reproduce the bid-response patterns and WTP estimates observed in actual survey data, and does conditioning on elicited beliefs improve accuracy?**

Nine LLM providers (accessed via OpenRouter) are evaluated:
`deepseek-chat-v3.1`, `deepseek-r1`, `gemini-2.5-flash`, `gemini-2.5-flash-lite`, `gpt-5-mini`, `kimi-k2`, `llama-4-scout`, `mistral-medium-3.1`, `mistral-small-3.2-24b-instruct`

---

## Repository Structure

```
Replication_and_Analysis_Code/
├── data/           # Datasets (large files on Google Drive; see data/README)
├── do/             # All Stata .do scripts
└── figures/        # Output figures (.png and .eps)
```

---

## do/ — Stata Scripts

All scripts use two global macros for paths. Set these at the top of each script (or in your Stata profile) before running:

```stata
global datadir  "path/to/data"
global figdir   "path/to/figures"
```

The `~*.stswp` files are Stata swap/lock files from open editing sessions — they can be ignored.

### Execution Order

Scripts are numbered to indicate the intended run order within each study branch. There is no single master `.do` file; run each branch in sequence.

#### Study 1 / Variants 1 & 2 (QSA — quasi-social-acceptability)

| Script | Purpose |
|--------|---------|
| `1_make_data_Var1Var2.do` | Imports the raw LLM Monte Carlo results (`final_part.dta`, produced by Alina), creates `person_variant_id` and `provider_id` keys, cleans demographic variables (income, education, gender, race, party), and saves `working_data.dta` |
| `2_make_figs_Var1Var2.do` | Generates bid-amount vs. propensity-to-vote figures for Variants 1 & 2, comparing actual QSA responses against synthetic (demographics-only and beliefs+demographics) by provider; saves figures to `figures/` |
| `2_make_figs_Var1Var2_panellvl.do` | Panel-level version of the same figures (one panel per belief question or provider) |

#### Study 1 / Variant 3 (Belief questions)

| Script | Purpose |
|--------|---------|
| `1_make_data_Var3.do` | Imports `Indiv_beliefs_data.dta`, creates `person_beliefQ_id` and `beliefQ_id` keys (13 belief questions mapped), cleans demographics identically to Var1Var2, saves `working_data_var3.dta` |
| `1b_make_data_Var3.do` | Secondary data-prep step for Variant 3 (additional cleaning or subset construction) |
| `2_make_figs_Var3.do` | Generates bid-amount vs. propensity-to-vote figures for each of the 13 belief questions (Qs 1–13 cover: global warming causation, policy priority, clean energy priority, renewable energy support, harm to future generations, developing countries, US residents, plant/animal species, personal harm, family discussion frequency, worry level, media attention, personal view); saves `bid_amount_actual_v_beliefQ*_Var3*.png` |

#### Study 2 / Forest WTP

| Script | Purpose |
|--------|---------|
| `1c_make_data_ForestWTP.do` | Constructs the Forest WTP working dataset from raw experiment data; creates choice-experiment structure (expands to 2 alternatives per situation), generates `actual_vote_ForestWTP.dta` for propensity-to-vote plots |
| `2b_logit_ForestWTP.do` | Estimates Forest WTP conditional logit models on actual survey data; computes WTP via `nlcom` (-β_attr / β_cost) |
| `2b_make_figs_ForestWTP.do` | Full figure-production script for Forest WTP results: propensity-to-vote plots (bounded and repeated designs, with and without beliefs), dot-and-95%CI WTP plots by provider (aggregated and per-provider); outputs `propensity_to_vote_*.eps/.png`, `dot_and_95CI_*.png` |

#### Replication of Paper Tables

| Script | Purpose |
|--------|---------|
| `Paper Replication_AK.do` | Replicates Tables 1–6 from the reference paper using `original_data.csv` (Study 2 raw survey): Table 1 (bid×vote tabulations), Table 2 (conditional logit — bounded and repeated samples), Table 4 (conditional logit with stated attribute non-attendance), Table 6 (WTP from `nlcom`). Tables 3 and 5 (mixed logit) are commented out (require `mixlogit`). |

#### Early Exploratory Analysis

| Script | Purpose |
|--------|---------|
| `Analysis_AK.do` | Early exploratory script (Alina Khindanova): imports `final_part.dta`, constructs QSA binary outcomes, plots propensity-to-vote curves for actual vs. synthetic data, runs logit models for actual/demographics-only/beliefs+demographics specifications, and computes WTP via `wtpcikr`. Includes provider-specific breakdowns for DeepSeek-v3, DeepSeek-R1, Gemini-2.5, Gemini-2.5-lite, Meta-LLaMA, and OpenAI. |
| `Chunk_code_AK.do` | Auxiliary chunking/helper code used during early development |

---

## figures/ — Output Figures

Figures are saved as `.png` (for previewing) and `.eps` (for paper submission). Key figures:

### Propensity-to-Vote Plots (Study 2 / Forest WTP)

| File | Description |
|------|-------------|
| `propensity_to_vote_withBeliefs_ForestWTP.eps/.png` | Bid amount vs. share voting yes — aggregated across providers, with beliefs conditioning |
| `propensity_to_vote_withoutBeliefs_ForestWTP.eps/.png` | Same, demographics-only conditioning |
| `propensity_to_vote_Bounded_withBeliefs_ForestWTP.png` | Bounded design, with beliefs |
| `propensity_to_vote_Random_withBeliefs_ForestWTP.png` | Repeated (random) design, with beliefs |
| `bid_amount_actual_v_withbeliefs.png/.eps` | Actual vs. synthetic (with beliefs) bid curves |
| `bid_amount_actual_v_withoutbeliefs.png` | Actual vs. synthetic (without beliefs) bid curves |
| `bid_amount_actual_v_with_beliefs.png` | Pooled version (all providers) |
| `bid_amount_actual_v_without_beliefs.png` | Pooled version (demographics only) |

### WTP Dot-and-CI Plots (Study 2 / Forest WTP)

Each plot shows point estimates and 95% CIs for synthetic WTP by LLM provider, with and without beliefs conditioning. The vertical line marks the actual WTP benchmark.

| File | Description |
|------|-------------|
| `dot_and_95CI_bounded_ForestWTP.png` | Bounded design, all providers, full scale |
| `dot_and_95CI_bounded_ForestWTP_NoOutliers.png` | Bounded design, outliers trimmed |
| `dot_and_95CI_bounded_ForestWTP_NoOutliers_v2.png` | Refined version |
| `dot_and_95CI_repeated_ForestWTP.png` | Repeated design, all providers, full scale |
| `dot_and_95CI_repeated_ForestWTP_NoOutliers.png` | Repeated design, outliers trimmed |
| `dot_and_95CI_repeated_ForestWTP_NoOutliers_v2.png` | Refined version |
| `dot_and_95CI_NCES.eps` | NCES specification |
| `dot_and_95CI_NCES_noLlama.png` | NCES specification, LLaMA excluded |

### Belief Question Plots (Variant 3)

`bid_amount_actual_v_beliefQ{N}_Var3.png` and `..._v2.png` — one panel per belief question (Q1–Q12), comparing actual bid-response curves against synthetic by provider.

`bid_amount_actual_v_beliefQ_Var3.png` — combined panel showing all belief questions at once.

---

## Data

The full dataset is too large to store in this repository and is hosted on Google Drive.
Access the data here: https://drive.google.com/drive/folders/1oTmV9N5PLXAQY6P8WeIX6znzgbLpp9FQ

Download the contents of that folder and place them in `data/` before running the `.do` scripts.
The `data/raw/` subfolder contains a small auxiliary file that is tracked in git.

See [`data/README.md`](data/README.md) for a full description of every file in the data folder.

---

## Software Requirements

- **Stata 15+** (some scripts use `mixlogit`, `wtpcikr`, `clogit`, `eststo`/`esttab`)
- Required user-written packages (install via `ssc install`):
  - `mixlogit`
  - `wtpcikr`
  - `esttab` / `estout`

---

## Notes

- File paths are hardcoded as Windows-style paths (`D:\Projects\LLM_CV\...`) in some scripts. Update `global datadir` and `global figdir` for your local environment before running.
- The `.stswp` files in `do/` are Stata editor swap files and can be safely ignored or deleted.
- `Paper Replication_AK.do` uses `original_data.csv` from `data/raw/Experiment2/` as its input — ensure that file is present before running.
- LLM providers 0–8 in the data files correspond to: deepseek-chat-v3.1 (0), deepseek-r1 (1), gemini-2.5-flash (2), gemini-2.5-flash-lite (3), gpt-5-mini (4), kimi-k2 (5), llama-4-scout (6), mistral-medium-3.1 (7), mistral-small-3.2-24b-instruct (8). *(Confirm this mapping against `provider_id_xwalk.dta`.)*
