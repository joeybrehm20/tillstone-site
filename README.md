# Tillstone Land Solutions — website

Static site for **tillstone.land**. Everything the browser needs lives in `site/`.

```
site/
  index.html          the whole site: 5 pages (Home, Services, Experience, About, Contact)
  favicon.svg         browser-tab icon (the layered-land logo)
  CNAME               custom domain for GitHub Pages
  assets/img/         photos (img-01 … img-20)
  assets/fonts/       Spectral + Public Sans (self-hosted, no Google Fonts call)
  assets/js/          page runtime + React (self-hosted, no CDN call)
```

## Editing with Claude

1. Open the Claude desktop app → Code → open this folder (`tillstone-site`).
2. Describe the change ("update Joey's bio", "swap the hero photo for the attached file",
   "add a fifth service"). Claude edits `site/index.html` / `site/assets/`.
3. Ask Claude to preview it (it runs `serve.ps1` and opens http://localhost:8765).
4. Ask Claude to publish — it commits and pushes to `main`, and GitHub Pages
   redeploys tillstone.land within about a minute.

## How the page is built

`index.html` is one file. Page content sits inside `<x-dc> … </x-dc>`:

- `<helmet>` — fonts, base CSS, and the `#mobile-layout` responsive rules.
- One `<main data-screen-label="…">` block per page, wrapped in `<sc-if>` so only the
  page matching the URL hash (`#home`, `#services`, …) renders.
- The `<script type="text/x-dc">` at the bottom holds the small React component that
  handles hash navigation, the photo-tab switchers, and the contact form
  (currently opens the visitor's mail client via `mailto:`).

Styles are inline on each element. The responsive layer at the top of the helmet
targets those inline styles with attribute selectors, so if you change e.g. a
`font-size:72px` heading, check the matching `[style*="font-size: 72px"]` rule too.

## Partner portraits

The four `<image-slot id="portrait-…">` elements on the About page are empty
placeholders. To fill one, drop a photo into `site/assets/img/` and replace the
`<image-slot …>` with an `<img>` of the same size/shape.

## Local preview

```powershell
powershell -ExecutionPolicy Bypass -File serve.ps1
```
then open http://localhost:8765.
