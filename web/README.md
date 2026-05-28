# Web

## Deployment

`web/index.html` is a fully self-contained single HTML file. Deploy it by serving it
at the `/wtp` path on alethic.ai.

No server-side rendering or build step is required.

## Data files

`web/assets/data/` contains pre-processed JSON data files used by the interactive
explorer. These are loaded at page load time and should be served alongside the HTML.

When the team provides actual model-level approval share data, update
`web/assets/data/approval_curves.json` with real values (replacing the `[]` placeholders).

## Dependencies

- Chart.js 4.4.1 (loaded from cdnjs at runtime)
- Google Fonts: EB Garamond, DM Sans, Fira Code

The page degrades gracefully without JavaScript — all static content (hero, methods,
citation) remains visible.
