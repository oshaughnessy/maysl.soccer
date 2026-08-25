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
words = [re.sub(r'\\([()\\])', r'\1', c[1:-1])
         for c in re.findall(r'\((?:\\.|[^()\\])*\)', blob)]

# 'x-none' is the language marker these calendars emit between text runs, so it
# doubles as a record separator.
for line in (l.strip() for l in ''.join(words).replace('x-none', '\n').split('\n')):
    # Font-encoding tables trail the real text. Left in, they carry control and
    # high-byte characters, grep then treats the stream as binary, and it prints
    # nothing at all -- even for lines that plainly match.
    if not re.fullmatch(r'[\x20-\x7e]+', line): continue
    if not re.search(r'[A-Za-z]', line): continue
    if re.fullmatch(r'\d{1,2}', line) or line in list('SMTWF'): continue
    print(line)
PY
