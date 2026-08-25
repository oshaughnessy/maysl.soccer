#!/usr/bin/env bash
# Static checks over the built site. Run with `make check`.
#
# Each check here exists because the corresponding mistake actually shipped:
#   liquid   - a stray {% %} in output means a template bug rendered as text
#   slashes  - `{% link x %}/#anchor` emits a double slash; a partial sweep of
#              this once "fixed" it in _pages while leaving schedules/ broken
#   links    - internal hrefs pointing at pages that don't exist
#   anchors  - #fragment links whose target id isn't on the destination page
#   orphans  - built pages nothing links to (two per-year schedule indexes sat
#              unreachable for years before anyone noticed)
set -uo pipefail
cd "$(dirname "$0")/.."
SITE="${1:-_site}"
fail=0
note() { printf '  %s\n' "$*"; }

[ -d "$SITE" ] || { echo "No $SITE — run 'make build' first."; exit 1; }

echo "== unrendered Liquid in output =="
if grep -rlE '\{%|\{\{' "$SITE" --include='*.html' 2>/dev/null | grep -v '/assets/' | head -5 | grep .; then
  fail=1
else note "none"; fi

echo "== {% link %} trailing-slash bug in source =="
if grep -rn '%[[:space:]]*}/#' --include='*.md' --include='*.html' --include='*.yml' . 2>/dev/null \
   | grep -v "^\./$SITE/" | head -10 | grep .; then
  fail=1
else note "none"; fi

echo "== broken internal links / anchors =="
python3 - "$SITE" <<'PY'
import os, re, sys, collections
site = sys.argv[1]
pages, ids, links = set(), collections.defaultdict(set), []
for root, _, files in os.walk(site):
    for f in files:
        if not f.endswith('.html'): continue
        full = os.path.join(root, f)
        url = '/' + os.path.relpath(full, site)
        pages.add(url)
        if url.endswith('/index.html'): pages.add(url[:-10])
        html = open(full, encoding='utf-8', errors='replace').read()
        ids[url] = set(re.findall(r'\bid="([^"]+)"', html))
        if url.endswith('/index.html'): ids[url[:-10]] = ids[url]
        for h in re.findall(r'href="(/[^"]*)"', html):
            links.append((url, h))
bad_page, bad_anchor = [], []
for src, href in links:
    path, _, frag = href.partition('#')
    if not path: continue
    fs = os.path.join(site, path.lstrip('/'))
    # a bare directory 404s on Pages unless it has an index.html
    resolves = (path in pages or path.rstrip('/') + '/' in pages
                or (os.path.isfile(fs))
                or os.path.isfile(os.path.join(fs, 'index.html')))
    if not resolves:
        bad_page.append((src, href)); continue
    if frag:
        target = path if path in ids else path.rstrip('/') + '/'
        if target in ids and frag not in ids[target]:
            bad_anchor.append((src, href))
for label, rows in (("missing page", bad_page), ("missing anchor", bad_anchor)):
    for src, href in sorted(set(rows))[:10]:
        print(f"  {label}: {href}  (linked from {src})")
    if len(set(rows)) > 10: print(f"  ... and {len(set(rows))-10} more {label}")
print("  none" if not bad_page and not bad_anchor else "")
sys.exit(1 if bad_page or bad_anchor else 0)
PY
[ $? -ne 0 ] && fail=1

echo "== orphan pages (nothing links to them) =="
python3 - "$SITE" <<'PY'
import os, re, sys
site = sys.argv[1]
linked, allp = set(), []
for root, _, files in os.walk(site):
    for f in files:
        if not f.endswith('.html'): continue
        full = os.path.join(root, f)
        url = '/' + os.path.relpath(full, site)
        allp.append(url)
        for h in re.findall(r'href="(/[^"#?]*)"', open(full, encoding='utf-8', errors='replace').read()):
            linked.add(h); linked.add(h.rstrip('/') + '/index.html')
# 404 and the site root are reachable without an inbound link
skip = re.compile(r'^/(404\.html|index\.html)$')
orphans = [p for p in sorted(allp)
           if not skip.match(p) and p not in linked and p[:-10] not in linked]
for p in orphans[:15]: print(f"  {p}")
print(f"  ... and {len(orphans)-15} more" if len(orphans) > 15 else ("  none" if not orphans else ""))
PY

echo
[ "$fail" -eq 0 ] && echo "OK" || echo "FAILURES above"
exit "$fail"
