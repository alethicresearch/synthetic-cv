# Code

## Structure

```
code/
├── simulation/     Alethic-ISM workflow graphs and persona/prompt templates
├── analysis/       Econometric estimation scripts (R/Stata)
└── figures/        Figure generation scripts (R)
```

## Requirements

- **R** ≥ 4.2 with packages: `tidyverse`, `survival`, `mlogit`, `krinsky` (see `analysis/install_packages.R`)
- **Alethic-ISM** for re-running simulations (see `simulation/README.md`)

## Quick start

```bash
# Replicate Study 1 WTP estimates
cd code/analysis
Rscript study1_estimation.R

# Replicate Study 2 conditional logit estimates
Rscript study2_estimation.R

# Regenerate WTP forest plot (Figure 4)
Rscript figures/figure4_wtp_s1.R
```

## Simulation

See `code/simulation/README.md` for instructions on re-running the LLM simulations
via Alethic-ISM.
