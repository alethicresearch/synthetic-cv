# Research Website

Source for the project research page, deployed via GitHub Pages at
https://alethicresearch.github.io/synthetic-cv/

## Deployment

`index.html` is a fully self-contained single HTML file. Deployed automatically on
push to `main` via the GitHub Actions workflow in `.github/workflows/pages.yml`.

No server-side rendering or build step is required.

## Contents

- `index.html` — main research page (interactive results explorer, methods, citation)
- `favicon.png` — site favicon
- `draft_*.pdf` — current paper draft, served directly from GitHub Pages

## Dependencies

- Chart.js 4.4.1 (loaded from cdnjs at runtime)
- Google Fonts: EB Garamond, DM Sans, Fira Code

The page degrades gracefully without JavaScript — all static content (hero, methods,
citation) remains visible.
