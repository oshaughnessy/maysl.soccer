# Analytics snapshots

Periodic exports from GA4, kept in the repo so findings outlive a terminal
session. **Not published** — `analytics` is in `_config.yml`'s `exclude` list, so
Jekyll never copies it into `_site`.

## Refresh

```sh
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/cloud-platform
./analytics/pull.sh
```

Writes two date-stamped TSVs. Old snapshots stay — the point is comparison over
time, so don't delete them.

| File | Source | Columns |
|------|--------|---------|
| `<date>-read-through.tsv` | GA4 | path, views, reached_90pct, read_through_pct |
| `<date>-pages-by-month.tsv` | GA4 | month, path, views |
| `<date>-search-queries.tsv` | Search Console | query, clicks, impressions, ctr_pct, avg_position |
| `<date>-search-pages.tsv` | Search Console | page, clicks, impressions, ctr_pct, avg_position |

GA4 property `330581274`, quota project `maysl-analytics-20260823`, Search
Console domain property `sc-domain:maysl.soccer`.

## Baseline: search, 2026-08-25

The first Search Console pull, covering Apr 2025 (when the property was
verified) onward. GA4 can say a visit came from organic search; only this says
what was typed.

**84% of search clicks are people who already know us** &mdash; 385 of 457 from
"maysl", "mountain area youth soccer", and variants. Discovery is the other 72.

Shown often, rarely clicked:

| Query | Impressions | CTR | Position |
|-------|-------------|-----|----------|
| soccer game length by age | 278 | 0.0% | 6.8 |
| mountain soccer | 121 | 10.7% | 9.9 |
| oakhurst soccer | 55 | 7.3% | 6.7 |
| u11 soccer half length | 41 | 0.0% | 13.0 |

Converting well but barely seen:

| Query | Impressions | CTR | Position |
|-------|-------------|-----|----------|
| youth soccer leagues near me | 14 | 92.9% | 3.0 |
| youth soccer near me | 14 | 71.4% | 2.9 |

Two things worth knowing before acting on this:

`/rules/` draws the most impressions of any page &mdash; 9,756 &mdash; and 20
clicks. It's ranking for a long tail of generic youth-soccer rule questions from
everywhere ("9v9 game length", "do u10 play offside", "12u soccer field
dimensions"), where the biggest single query has 13 impressions. Those searchers
aren't our constituency and can't be served by a league in Oakhurst, so this is
mostly a curiosity rather than an opportunity. The division table does answer
those questions well, if ranking ever improves on its own.

The local queries are the real gap. "oakhurst soccer" sits at 7.3% CTR from
position 6.7, and the "near me" queries convert at 71&ndash;93% but are shown
only 14 times. Meta descriptions naming the towns went in on 2026-08-24, so the
next pull is the first that can show whether that moved anything.

## Baseline: 2026-08-24

Taken the day the answer-first restructure went live, so it measures the **old**
pages. Read-through is the share of visitors who reached 90% scroll depth — the
number that work was meant to move.

| Page | Views | Read-through | Notes |
|------|-------|--------------|-------|
| `/registration/` | 4,639 | 44% | short page |
| `/parents/` | 1,654 | 32% | restructured |
| `/coaches/` | 1,327 | 21% | restructured |
| `/coachreg/` | 817 | 25% | restructured |
| `/rules/` | 787 | 26% | restructured |
| `/contact/` | 763 | 63% | short page |
| `/faq/` | 542 | 44% | |
| `/refs/` | 391 | 19% | restructured |
| `/about/` | 282 | 65% | short page |
| `/refs/training/` | 57 | 25% | 57 views in four years |

Read-through tracked inversely with length: the short pages (`/about/`,
`/contact/`) ran 63–65%, the long ones 19–26%. That gap is what the answer boxes
target.

**Re-pull around Dec 2026**, after a full season on the new pages, and compare.
If the long pages haven't moved, the answer boxes aren't earning their place.

## Caveats

- Event-level data (scroll, paths, device splits) was on GA4's default 2-month
  retention until 2026-08-23, when it was raised to 14 months. Detail from before
  roughly June 2026 is thin or missing. Aggregated page views are unaffected and
  reach back to 2022.
- Local browsing does **not** pollute the numbers. The theme gates the GA4 tag on
  `jekyll.environment == 'production'`, and `make serve` runs in development, so
  no tag is emitted locally. Only the Actions build sets `JEKYLL_ENV: production`.
