---
name: season-rollover
description: Roll the MAYSL site over to a new soccer season — rebuild game_days from the school district's fall break, update the season tag, fees, and registration links, and verify the schedule marker gates correctly. Use when starting a new season, when asked to "roll over the season", set up next year, or update game_days / the season tag.
---

# Season Rollover

Yearly, ~7 steps across 4 files. Several steps fail **silently** if skipped: miss a
`tags:` line and the schedule marker just never appears; miss the `_config.yml`
copies of `label` and the sidebar shows the wrong season all year. Work the list.

See `PHASES.md` for what each `season.yml` field drives day to day.

## 1. Find the school district's fall break

The scheduling rule is: **play the first weekend of a break, skip the last.**

MAYSL families span three districts, but only two govern the schedule:

| District | Schools | Governs the schedule? |
|----------|---------|----------------------|
| Bass Lake JUESD | Wasuma, Oakhurst Elementary, Oak Creek | **yes** |
| Yosemite Unified | Coarsegold, Rivergold, Yosemite High | **yes** |
| Chawanakee Unified | Spring Valley, Minarets, North Fork | no |

BLSD and YUSD usually align on breaks; we schedule to them. Chawanakee often
differs, and we don't follow it. **If BLSD and YUSD disagree, stop and ask** --
that's a league decision, not something to infer.

Break dates come from the [Bass Lake JUESD calendar
page](https://www.basslakeschooldistrict.com/29343_2), which links a Google Drive
PDF, and the [YUSD calendar
page](https://www.yosemiteusd.com/apps/pages/index.jsp?uREC_ID=4377220&type=d&pREC_ID=2580568).
YUSD publishes through BoardDocs, which serves a viewer rather than the file, so
that one usually needs downloading by hand.

Save each year's PDF into `reference/calendars/` as
`<school-year>-<district>.pdf` so it can be re-read later without hunting for
the link again. `reference/README.md` has the download command and a reader
that works without a PDF viewer -- use that rather than the copy below, which
is kept only so this page reads on its own.

```sh
curl -sL "https://drive.google.com/uc?export=download&id=<FILE_ID>" -o cal.pdf
python3 - <<'PY'
import re, zlib
data = open('cal.pdf','rb').read()
texts = []
for m in re.finditer(rb'stream\r?\n(.*?)endstream', data, re.S):
    for args in ((), (-15,)):
        try: texts.append(zlib.decompress(m.group(1), *args)); break
        except Exception: pass
blob = b"\n".join(texts).decode('latin-1')
words = [re.sub(r'\\([()\\])', r'\1', c[1:-1])
         for c in re.findall(r'\((?:\\.|[^()\\])*\)', blob)]
for l in (l.strip() for l in ''.join(words).replace('x-none','\n').split('\n')):
    if l and not re.fullmatch(r'\d{1,2}', l) and l not in list('SMTWF'):
        print(l)
PY
```

Look for `Fall Break`, plus `Thanksgiving Break` (the season ends the Saturday
before Thanksgiving) and `First Day School` (practices start 2–3 weeks before
opening day).

## 2. Build `game_days`

Every Saturday from opening day through the Saturday before Thanksgiving, minus
the skipped one.

```sh
python3 - <<'PY'
import datetime
first = datetime.date(2027, 9, 11)     # opening Saturday
thanksgiving = datetime.date(2027, 11, 25)
skip = {datetime.date(2027, 10, 16)}   # last weekend of fall break
d, last = first, thanksgiving - datetime.timedelta(days=4)
while d <= last:
    if d not in skip: print(f'  - "{d}"')
    d += datetime.timedelta(days=7)
PY
```

**Show the list and the skipped date to the user for confirmation before
writing it.** Which weekend counts as "the last weekend of the break" is an
inference from a district PDF, and getting it wrong puts the marker on the wrong
column for half the season.

This list is the single source of truth for the season's shape — opening day is
`game_days | first`, and the marker's position is an index into it. The skip
**must** live here; calendar arithmetic can't infer it.

## 3–5. Update `_data/season.yml`

```yaml
year:  2027
label: "2027/28"
tag: 2027-season          # also gates the schedule marker and home-page posts
phase: signup
registration_open: true
schedules_posted: false
dates:
  practices_start: "2027-08-23 PDT"   # Monday of the week rec practices begin
game_days: [ ... from step 2 ... ]
adult:                              # winter league; tight signup window
  promo_starts:  "2027-10-09 PDT"   # start advertising mid-October, mid-season
  signups_open:  "2027-11-29 PST"   # Monday after Thanksgiving and Black Friday
  first_game:    "2028-01-08 PST"   # 1st or 2nd weekend of January
fees:
  clinic: 90     # U4-U5; includes a jersey
  standard: 115
  jersey: 20     # non-clinic players who need one
register:        # new GotSport program links each year — ask for all three
  players:  ...
  coaches:  ...
  referees: ...
```

## 6. The two hardcoded copies of `label`

`_config.yml`'s `defaults` blocks each carry a sidebar `title: <label> Signups`
(~lines 159 and 179). Front matter and `_config.yml` can't evaluate Liquid, so
these can't read `season.yml`. Update both.

**`_config.yml` changes need a `make serve` restart** — unlike `_data/`, Jekyll
does not reload config.

## 7. Tag the season's content

Posts and schedule pages both need the new tag, plural key:

```yaml
tags: 2027-season schedule u10     # schedule pages
tags: 2027-season signup players   # posts
```

Then move the previous season down to "Past Schedules" in `_pages/schedules.md`.

## Verify

With `make serve` running:

```sh
# opening day flows from game_days into all three of these
curl -s http://localhost:4000/ | grep -o 'Target date for 1st games is [^<.]*'
curl -s http://localhost:4000/schedules/ | grep -o 'Opening Day is [^<.]*'
curl -s http://localhost:4000/parents/ | grep -o 'games Saturdays[^<]*'

# marker state, on a page for the new season
curl -s http://localhost:4000/schedules/2027/U10-boys.html | grep -A5 'current season'
```

`marker drawn: false` with a mismatched `this page` means the tag is wrong.
`false` with matching tags means today is outside the season window — expected
until a week before opening day.

Confirm the gate works **both ways**: an archived page must show
`marker drawn: false` while a current-season page shows `true`. Temporarily
pointing `tag:` at an old season is a quick way to prove the positive case
before real pages exist — restore it afterward.

Finally, sweep for Liquid leaks, since `season.yml` feeds many pages:

```sh
for u in / /faq/ /parents/ /schedules/ /registration/ /refs/; do
  printf "%s %s leaks:%s\n" "$u" \
    "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:4000$u)" \
    "$(curl -s http://localhost:4000$u | grep -c '{{\|{%\|Liquid')"
done
```
