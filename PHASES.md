# Season Phases

Everything that changes as the season progresses lives in
[`_data/season.yml`](_data/season.yml). It's in `_data/` rather than `_config.yml`
so `make serve` picks up edits without a restart.

## The one line you change most

```sh
make phase              # show the current phase and the options
make phase PHASE=season # set it, with a checklist of what else to update
```

That edits one line in `_data/season.yml`:

```yaml
phase: preseason
```

`phase` drives two things on the home page:
[`_includes/season-status.html`](_includes/season-status.html), the facts block,
and [`_includes/season-card.html`](_includes/season-card.html), the call to
action. It's set by hand on purpose: GitHub Pages only rebuilds on push, so a
date-computed value would sit stale between commits.

| `phase` | Roughly | Status block leads with | Card |
|---|---|---|---|
| `signup` | Jun–Aug | signups open, cost, deadlines | Sign Up for Fall → `/register/` |
| `preseason` | late Aug | teams forming, practices, first games | New to MAYSL? → `/parents/` |
| `season` | Sep–Nov | next game day, where, schedules | Game Schedules → `/schedules/` |
| `wrapup` | Nov–Dec | season complete, photos, adult league | Season News → `/news/` |
| `offseason` | Dec–May | adult league, spring travel, next fall | Adult Winter Soccer → `/adult/` |

The facts live in the status block and the card carries none of them &mdash; when
both stated the same dates they drifted apart within a day.

## The other switches

| Field | Effect when changed |
|---|---|
| `registration_open` | `true` adds "Late signups still welcome" to the preseason card |
| `schedules_posted` | `true` swaps the season card to "Find Your Schedule" and removes "Schedule coming soon!" from `/schedules/` |
| `tag` | Which posts appear on the home page, **and** which schedule pages draw the "you are here" marker |
| `game_days` | Opening day everywhere on the site, and the marker's position |
| `fees` | Rendered on `/parents/` and `/registration/` |
| `register` | The three GotSport buttons |
| `practices_start` | Monday of the week rec practices begin; rendered as "the week of …" |
| `adult.promo_starts` | When the season block starts advertising the winter adult league &mdash; mid-October, while games are still on |
| `adult.signups_open` | Flips the message to "signups are open now" |
| `adult.first_game` | Named in both the late-season and wrap-up messages |

## Through the year

| When | Do this |
|---|---|
| Registration opens (June) | `phase: signup`, `registration_open: true`, check the three `register` links and `fees` |
| Rosters lock (late Aug) | `registration_open: false` |
| Teams forming, practices near | `phase: preseason`, set `practices_start` |
| Division schedules go up | `phase: season`, `schedules_posted: true`, and **tag the new pages** (below) |
| Last game played | `phase: wrapup` |
| Winter adult league | `phase: offseason` |

The schedule marker turns itself on a week before opening day and off after the
last game — no phase flip needed for that.

## Posting a new season's schedules

New division pages **must** carry the season tag or the marker stays dark:

```yaml
---
title: 2027 U10 Boys Schedule
tags: 2027-season schedule u10
division: U10
sidebar:
  nav: schedules-by-division
---
```

Plural `tags:`, not `tag:`. [`_includes/schedule.html`](_includes/schedule.html)
compares `page.tags` against `season.yml`'s `tag`, so an archived page never
picks up the current season's marker.

Then move the previous season down to "Past Schedules" on
[`_pages/schedules.md`](_pages/schedules.md).

## Rolling over to a new season

Use the `season-rollover` skill &mdash; it has the full checklist, the district
calendar sources, and the `game_days` generator. The short version: only Bass
Lake JUESD and Yosemite Unified govern our schedule (not Chawanakee), we play
the first weekend of a break and skip the last, and the skipped weekend has to
be written into `game_days` because no arithmetic can infer it.

## Checking your work

Every schedule page carries an HTML comment explaining the marker's state:

```
* current season: 2026-season
* this page: 2026-season schedule u10
* season: 2026-09-12 .. 2026-11-21 (10 game days)
* marker drawn: true
* active game day: 6
```

`marker drawn: false` with a mismatched `this page` means the tag is wrong or
missing. `false` with matching tags means today is outside the season window.

Quick check from a terminal while `make serve` runs:

```sh
curl -s http://localhost:4000/schedules/2026/U10-boys.html | grep -A5 'current season'
```
