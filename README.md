# Can LLMs Estimate Willingness to Pay?

**Evidence from Two Contingent Valuation Replications**

Trevor Woolley<sup>†</sup> (UC Berkeley) · Sankalpa Ghose (NUS, Alethic Research) · Alina Khindanova (UT San Antonio) · Kasra Rasaee (Bloomberg, Alethic Research) · Bob Fischer<sup>†</sup> (Texas State)

[Paper](https://github.com/alethicresearch/synthetic-cv/blob/main/paper/draft_6.01.26_SYNTH_CV_simulation.pdf) · [Research Page](https://alethicresearch.github.io/synthetic-cv/) · [Cite](#citation)

---

## Overview

We assess whether large language models (LLMs) can substitute for human respondents
in referendum-style contingent valuation (CV). Using individual-level data from two
published CV studies, we construct synthetic personas one-to-one from each respondent's
demographic and belief responses, prompt ten frontier and mid-tier LLMs to act as those
respondents, and compare synthetic willingness to pay (WTP) to published human-survey
benchmarks of $162 and $56.53 per household per year.

**Key findings:**
- Naive synthetic CV does not recover human-survey benchmarks
- Synthetic approval-bid curves are systematically flatter than empirical curves across
  both studies and almost every model
- Across-LLM heterogeneity is large and is not rescued by ensemble averaging
- The marginal value of belief inputs is highly context-dependent

## Studies Replicated

| Study | Policy | Benchmark WTP | N | Elicitation |
|-------|--------|--------------|---|-------------|
| Aldy, Kotchen & Leiserowitz (2012) | US 80% Clean Energy Standard by 2035 | $162/hh/yr | 1,010 | Single-bounded referendum |
| Giguere, Moore & Whitehead (2020) | NC Hemlock forest protection | $56.53/hh/yr | 907 | Bounded + random-cost choice |

## LLMs Evaluated

GPT-5, GPT-5-mini, Gemini 2.5 Flash, Gemini 2.5 Flash-Lite, DeepSeek-V3 (Chat),
DeepSeek-R1, Mistral Medium 3.1, Mistral Small 3.2 (24B-Instruct), Kimi-K2, Llama-4 Scout

## Simulation Platform

All simulations were run on [Alethic-ISM](https://github.com/alethicresearch/alethic-ism),
an open-source AI research workbench for composing and executing computational graphs
with versioned, immutable states. Developed by Rasaee & Ghose (2025).

## Repository Structure

```
paper/                    Paper draft (LaTeX), synced from Overleaf via git subtree
replication_analysis_code/  All Stata scripts and output figures for replication
  do/                     Stata .do scripts (numbered execution order)
  figures/                Output figures (.png and .eps)
  data/                   Working datasets (large files on Google Drive; see data/README)
research_website/         Source for the GitHub Pages research page
  index.html              Self-contained research page (interactive results explorer)
alethic-ism/              Simulation platform (git submodule)
```

To pull the latest paper draft from Overleaf:
```bash
git subtree pull --prefix=paper overleaf master --squash
git push origin main
```

## Data Access

**Replication datasets** (Stata format): archived on Zenodo at
[https://doi.org/10.5281/zenodo.20754919](https://doi.org/10.5281/zenodo.20754919),
subject to the data-use restrictions of the original studies. This is the
citable, permanent archive — cite this DOI when referencing the data.

Additional intermediate/working files not included in the Zenodo archive
remain available on Google Drive; see
[`replication_analysis_code/data/README.md`](replication_analysis_code/data/README.md)
for the full file inventory and Drive link.

**Original human-survey data**: not redistributed per data-use agreements with the original authors.
Request Study 1 data from Aldy/Kotchen/Leiserowitz and Study 2 data from Giguere/Moore/Whitehead directly.

## Replication

The replication code is in `replication_analysis_code/do/`. Scripts are numbered by
execution order within each study branch. See
[`replication_analysis_code/README.md`](replication_analysis_code/README.md)
for the full script inventory and run order.

Requirements: Stata 15+, with `mixlogit`, `wtpcikr`, and `esttab` installed via `ssc install`.

## Citation

```bibtex
@article{woolley2026synthetic,
  title={Can Large Language Models Estimate Willingness to Pay?
         Evidence from Two Contingent Valuation Replications},
  author={Woolley, Trevor and Ghose, Sankalpa and Khindanova, Alina
          and Rasaee, Kasra and Fischer, Bob},
  journal={[Journal TBD]},
  year={2026},
  note={Preprint: [DOI TBD]. Data and code: https://github.com/alethicresearch/synthetic-cv}
}
```

## License

Code: MIT License  
Data (synthetic responses): CC BY 4.0  
Paper: © Authors (all rights reserved until published; preprint freely available)

## Contact

Corresponding authors: Trevor Woolley — trevor_woolley@berkeley.edu · Bob Fischer — fischer@txstate.edu  
Platform questions: Kasra Rasaee / Sankalpa Ghose — research@alethic.ai
