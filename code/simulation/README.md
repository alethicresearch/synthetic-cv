# Simulation

All simulations were run on [Alethic-ISM](https://github.com/alethicresearch/alethic-ism).

## Setup

```bash
pip install alethic-ism
```

See the Alethic-ISM documentation for provider API key configuration.

## Workflow graphs

Alethic-ISM workflow definitions are in `workflows/`. Each graph encodes a complete
experiment as a directed acyclic graph: respondents × conditions × models.

## Persona templates

Production persona templates are in `personas/v6.3/`. The template constructs a
natural-language description of each respondent from their individual-level survey data.

## CV prompt templates

- `prompts/study1_nces.txt` — Study 1 (NCES clean energy standard) CV prompt
- `prompts/study2_hwa.txt` — Study 2 (HWA hemlock forest) CV prompt

Each template includes slot labels for bid amount and randomized treatment attributes.

## Running the simulation

```bash
# Run Study 1 simulation
alethic-ism run workflows/study1_nces.yaml

# Run Study 2 simulation
alethic-ism run workflows/study2_hwa.yaml
```

Output is written to `data/synthetic/` per the schema in `data/README.md`.
