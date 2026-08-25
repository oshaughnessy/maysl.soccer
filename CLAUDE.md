# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Static website for the Mountain Area Youth Soccer League (MAYSL), built with Jekyll and the [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) theme, hosted on GitHub Pages at https://maysl.soccer.

## Commands

```bash
make install      # bundle install
make build        # jekyll build
make serve        # jekyll serve with livereload on port 4000
make update       # bundle update --all
make lint         # yamllint _config.yml
```

`make serve` needs no setup step � it reads `_config.yml` directly.

## Architecture

### Theme & Styling

Uses `mmistakes/minimal-mistakes@4.24.0` via `remote_theme` in production and the `minimal-mistakes-jekyll` gem locally. The active skin is set in `_config.yml` (`minimal_mistakes_skin`). Custom skins live in `_sass/minimal-mistakes/skins/` � currently active: `maysl-winter-2026`.

### Content Structure

- **`_pages/`** � primary site pages (about, contact, schedules, coaches, parents, registration, rules, FAQ, etc.)
- **`_posts/`** � league news and announcements; paginated 4/page, most recent 2 shown on home
- **`schedules/`** � season schedules organized by year, then age division (U5�U16), in both Markdown and PDF
- **`_data/navigation.yml`** � all nav menus: `main`, `signups`, `schedules`, `schedules-by-division`, `sidebar`, `off-season`, `coaching`, `rules`
- **`files/`** � PDFs, logos, and images linked from pages
- **`_includes/`** � reusable components: `feature-card.html`, `schedule.html`, `section-header.html`, `image-caption.html`, `nav-item-with-icon.html`
- **`_layouts/home.html`** � custom home layout with feature cards

### Season Data

`_data/season.yml` is the single source of truth for everything that changes with
the season: `phase`, `game_days`, fees, registration links, and the season post
tag. Read **`PHASES.md`** before changing any of it — it documents what each field
drives and the annual rollover checklist.

Two things that file can't cover: `_config.yml`'s `defaults` sidebar titles hold a
hardcoded copy of `label` (front matter and config can't evaluate Liquid), and
`_config.yml` edits require a `make serve` restart.

### Local Gotchas

Landmines that cost real debugging time here:

- **Quoted {% raw %}`{% include %}`{% endraw %} params are never Liquid-rendered**,
  and nested quotes inside them break Jekyll's param parser outright. Build the
  string with `capture` first and pass the variable unquoted.
- **Liquid tokenizes tags inside {% raw %}`{% comment %}`{% endraw %} blocks.**
  An unmatched {% raw %}`{% capture %}`{% endraw %} in a comment is a parse
  error. (Hence the `{% raw %}` wrappers in this list &mdash; Liquid runs before
  Markdown, so backticks alone don't protect these examples. Writing this file
  without them broke a deploy.)
- **A Liquid error silently freezes `_site`** — the watcher keeps running and the
  served page goes stale. Compare `_site/index.html`'s mtime against the source
  before assuming a code bug, and check the `make serve` terminal.
- **Browsers cache `/assets/css/main.css`.** Hard-reload before concluding a
  style change didn't apply.
- **Headings inside a collapsed `<details>` still appear in the sticky TOC**, so
  clicking them jumps to invisible content. Keep headings outside.
- **`padding` is ignored on a table with `border-collapse: collapse`** (per spec).
  Use `separate` with `border-spacing: 0`.

### Frontmatter Defaults

Set in `_config.yml` under `defaults`. Pages get `layout: single` with a sticky TOC and `nav: signups` sidebar. Posts get `layout: single` with the same sidebar, `read_time: false`, and related posts enabled. Override per-file as needed.

### Local vs Production Config

There's only one config now. `_config.yml` uses `theme: minimal-mistakes-jekyll` from the bundled gem, and CI builds with `bundle exec jekyll build`, so local and production resolve the theme identically and `Gemfile.lock` is the single source of its version.

The old `remote_theme` + `local.yml` + `make local-config` arrangement existed because the legacy GitHub Pages builder ran its own gemset. That builder is gone; `make local-config` is now a no-op and `local.yml` can be deleted.

## Key Files

| File | Purpose |
|------|---------|
| `_config.yml` | Jekyll config: URL, theme, skin, analytics (GA4 G-3YQ3FTWMRY), plugins, defaults |
| `PHASES.md` | How season phases work; annual rollover checklist |
| `_data/season.yml` | Season phase, game days, fees, registration links, post tag |
| `analytics/` | GA4 snapshots + `pull.sh` to refresh; excluded from the build |
| `_data/navigation.yml` | All navigation menus |
| `_sass/minimal-mistakes/skins/` | Custom color skins |
| `_includes/feature-card.html` | Card component used on home page |
| `_includes/schedule.html` | Schedule rendering include |
| `_layouts/home.html` | Home page layout |
| `CNAME` | Custom domain for GitHub Pages |

## Deployment

No CI/CD. Build locally with `make build`, then push to the `main` branch � GitHub Pages deploys automatically.
