# Season Phases

Everything that changes as the season progresses lives in
[`_data/season.yml`](_data/season.yml). It's in `_data/` rather than `_config.yml`
so `make serve` picks up edits without a restart.

## The one line you change most

```yaml
phase: preseason
```

`phase` selects which card the home page shows, via
[`_includes/season-card.html`](_includes/season-card.html). It's set by hand on
purpose: GitHub Pages only rebuilds on push, so a date-computed value would sit
stale between commits.

| `phase` | Roughly | Home card | Button goes to |
|---|---|---|---|
| `signup` | Jun–Aug | "Fall Signups!" | `/register/` |
| `preseason` | late Aug | "Getting Ready for Fall" | `/parents/` |
| `season` | Sep–Nov | "Games Have Started" / "Find Your Schedule" | `/schedules/` |
| `wrapup` | Nov–Dec | "Season Wrap-Up" | `/news/` |
| `offseason` | Dec–May | "Off-Season Soccer" | `/adult/` |

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

1. **Look up the school district's fall break.** The rule is: *play the first
   weekend of a break, skip the last.* The break dates come from the
   [Bass Lake JUESD calendar](https://www.basslakeschooldistrict.com/29343_2).
2. **Build `game_days`** — every Saturday from opening day through the Saturday
   before Thanksgiving, minus the skipped one. This list is the single source of
   truth for the season's shape; opening day is `game_days | first`.
   The skip has to be written here. It can't be derived from calendar
   arithmetic, and assuming an unbroken run of weeks put the marker one column
   too far right for half of the 2026 season.
3. **`year`, `label`, `tag`** — e.g. `2027`, `"2027/28"`, `2027-season`.
4. **New GotSport program links** for players, coaches, and referees.
5. **`fees`** — adjusted annually.
6. **Two hardcoded copies of `label`** in
   [`_config.yml`](_config.yml) (the `defaults` sidebar titles, ~lines 159 and
   179). Front matter and `_config.yml` can't evaluate Liquid, so these can't
   read from `season.yml`. **Changing `_config.yml` needs a `make serve`
   restart.**
7. **Tag that season's posts** `tags: <year>-season …` so they show on the home
   page.

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
