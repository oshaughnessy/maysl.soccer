#!/usr/bin/env bash
# Print the dated entries from a school district calendar PDF.
#
#   ./bin/read-calendar.sh reference/calendars/2026-27-bass-lake-juesd.pdf
#   ./bin/read-calendar.sh <pdf> | grep -E 'Break|First Day'
#
# pdftoppm isn't installed here, so this inflates the PDF's own streams and
# pulls the text-showing operators out of them. Good enough for a one-page
# district calendar; not a general PDF extractor.
set -euo pipefail

PDF="${1:-}"
if [ -z "$PDF" ] || [ ! -f "$PDF" ]; then
  echo "usage: $0 <calendar.pdf>" >&2
  echo "saved calendars:" >&2
  ls -1 "$(dirname "$0")/../reference/calendars/"*.pdf 2>/dev/null >&2 || echo "  (none yet)" >&2
  exit 1
fi

python3 - "$PDF" <<'PY'
import re, sys, zlib

data = open(sys.argv[1], 'rb').read()
if not data.startswith(b'%PDF'):
    sys.exit(f"{sys.argv[1]} isn't a PDF -- BoardDocs and Google Drive both serve "
             "an HTML viewer unless you use a direct download link.")

streams = []
for m in re.finditer(rb'stream\r?\n(.*?)endstream', data, re.S):
    for args in ((), (-15,)):
        try:
            streams.append(zlib.decompress(m.group(1), *args)); break
        except Exception:
            pass

blob = b"\n".join(streams).decode('latin-1')
runs = [re.sub(r'\\([()\\])', r'\1', c[1:-1])
        for c in re.findall(r'\((?:\\.|[^()\\])*\)', blob)]
joined = ''.join(runs)

def printable(line):
    # Font-encoding tables trail the real text. Left in, they carry control and
    # high-byte characters, grep then treats the stream as binary, and it prints
    # nothing at all -- even for lines that plainly match.
    return (re.fullmatch(r'[\x20-\x7e]+', line)
            and re.search(r'[A-Za-z]', line)
            and not re.fullmatch(r'\d{1,2}', line)
            and line not in list('SMTWF'))

# Two shapes of calendar PDF turn up. Bass Lake emits an 'x-none' language
# marker between text runs, which doubles as a record separator. Yosemite
# fragments text per-glyph for kerning, so there's nothing to split on -- for
# those, join everything and show a window around each date expression.
if 'x-none' in joined:
    for line in (l.strip() for l in joined.replace('x-none', '\n').split('\n')):
        if line and printable(line):
            print(line)
else:
    text = re.sub(r'\s+', ' ', joined)
    MONTH = r'(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?'
    DATE = MONTH + r'\s*\d{1,2}(?:\s*-\s*(?:' + MONTH + r'\s*)?\d{1,2})?'
    seen = set()
    for m in re.finditer(DATE, text):
        # a window either side, since the label sometimes leads and sometimes trails
        lo, hi = max(0, m.start() - 34), m.end() + 34
        window = text[lo:hi]
        # keep only windows that carry a word, not just a run of day numbers
        words = re.findall(r'[A-Za-z]{3,}', window)
        if not words:
            continue
        key = m.group(0)
        if key in seen:
            continue
        seen.add(key)
        if printable(window):
            print(f"{m.group(0):22} ...{window}...")
PY
