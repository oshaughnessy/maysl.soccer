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

`pdftoppm` isn't installed here, so pull the text out of the PDF streams:

```sh
python3 - reference/calendars/2026-27-bass-lake-juesd.pdf <<'PY'
import re, sys, zlib
data = open(sys.argv[1], 'rb').read()
texts = []
for m in re.finditer(rb'stream\r?\n(.*?)endstream', data, re.S):
    for args in ((), (-15,)):
        try: texts.append(zlib.decompress(m.group(1), *args)); break
        except Exception: pass
blob = b"\n".join(texts).decode('latin-1')
words = [re.sub(r'\\([()\\])', r'\1', c[1:-1])
         for c in re.findall(r'\((?:\\.|[^()\\])*\)', blob)]
for line in (l.strip() for l in ''.join(words).replace('x-none', '\n').split('\n')):
    # Drop the font-encoding table that trails the real text. Without this the
    # output carries control and high-byte characters, grep decides the stream
    # is binary, and it prints nothing even when there is a match.
    if not re.fullmatch(r'[\x20-\x7e]+', line): continue
    if not re.search(r'[A-Za-z]', line): continue
    if re.fullmatch(r'\d{1,2}', line) or line in list('SMTWF'): continue
    print(line)
PY
```

The dated entries come out near the end &mdash; look for `Fall Break`,
`Thanksgiving Break`, and `First Day School`.

## What's on file

| File | Notes |
|------|-------|
| `calendars/2026-27-bass-lake-juesd.pdf` | Board approved 12/10/2025. Fall Break Oct 12&ndash;16, so 10/10 is played and 10/17 is skipped. Thanksgiving Break Nov 23&ndash;27. First day Aug 13. |
