# commonfolklabs.com

Landing page for Commonfolk Labs. Static, single page, no build step, no dependencies.

## Files

| File | Purpose |
|---|---|
| `index.html` | The entire site — inline CSS, no external requests |
| `404.html` | Not-found page served by GitHub Pages |
| `CNAME` | Tells GitHub Pages to serve at `commonfolklabs.com` |

## Local preview

Open `index.html` in a browser. That's it.

## Deploying

Pushing to `main` publishes automatically via GitHub Pages.

## DNS

The domain is registered with HostingRaja. Apex `A` records point at GitHub Pages
(`185.199.108–111.153`) and `www` is a `CNAME` to `shivaraj-arch.github.io`.

## Notes

- Light and dark themes both supported via `prefers-color-scheme`.
- No analytics, no fonts, no CDN — the page makes zero external requests.
- Product subdomains (`dani.`, `court.`, `finance.`) are referenced on the page as
  plain text, not links, until they actually resolve.
