# Reference

Source documents we consult but don't publish. `reference` is in `_config.yml`'s
`exclude` list, so Jekyll never copies it into `_site`.

Files that *are* meant to be linked from pages belong in `files/` instead.

## calendars/

School district academic calendars, named `<school-year>-<district>.pdf`. The
season schedule is built from these &mdash; see the `season-rollover` skill.

| District | Governs our schedule? | Source |
|----------|----------------------|--------|
| Bass Lake JUESD | **yes** | [calendars page](https://www.basslakeschooldistrict.com/29343_2) &rarr; Google Drive link |
| Yosemite Unified | **yes** | [calendars page](https://www.yosemiteusd.com/apps/pages/index.jsp?uREC_ID=4377220&type=d&pREC_ID=2580568) &rarr; BoardDocs |
| Chawanakee Unified | no | Spring Valley, Minarets, North Fork |

BLSD and YUSD usually align on breaks and we schedule to them. Chawanakee often
differs and we don't follow it.

Bass Lake's PDF downloads directly:

```sh
curl -sL "https://drive.google.com/uc?export=download&id=<FILE_ID>" \
  -o reference/calendars/<year>-bass-lake-juesd.pdf
```

YUSD publishes through BoardDocs, which serves a viewer rather than the file, so
that one has to be saved by hand from the browser.

### Reading a calendar without a PDF viewer

```sh
make calendar CAL=reference/calendars/2026-27-bass-lake-juesd.pdf
```

or `./bin/read-calendar.sh <pdf>`. Pipe it through grep for the dates you want:

```sh
make calendar CAL=reference/calendars/2026-27-bass-lake-juesd.pdf \
  | grep -E 'Break|First Day|Labor Day'
```

The dated entries come out near the end &mdash; look for `Fall Break`,
`Thanksgiving Break`, and `First Day School`.

## What's on file

| File | Notes |
|------|-------|
| `calendars/2026-27-bass-lake-juesd.pdf` | Board approved 12/10/2025. Fall Break Oct 12&ndash;16, Thanksgiving Break Nov 23&ndash;27, first day Aug 13. |
| `calendars/2026-27-yosemite-usd.pdf` | Board approved 6/25/2025. **Identical break weeks**: Fall Break Oct 12&ndash;16, Thanksgiving Nov 23&ndash;27, first day Aug 13, last day June 11. |

For 2026-27 the two governing districts agree, which confirms the fall-break
skip: **10/10 is played, 10/17 is skipped.** Check this again each year rather
than assuming &mdash; if BLSD and YUSD ever diverge, that's a league decision.

The two PDFs are built differently, and the reader handles both: Bass Lake emits
an `x-none` marker between text runs that doubles as a record separator, while
Yosemite fragments text per glyph for kerning, so there's nothing to split on.
For that shape the reader joins everything and prints a window around each date
expression instead.
