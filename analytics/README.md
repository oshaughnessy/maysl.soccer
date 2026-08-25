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

| File | Columns |
|------|---------|
| `<date>-read-through.tsv` | path, views, reached_90pct, read_through_pct |
| `<date>-pages-by-month.tsv` | month, path, views |

Property `330581274`, quota project `maysl-analytics-20260823`.

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
