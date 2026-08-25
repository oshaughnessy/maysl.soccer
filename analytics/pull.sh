#!/usr/bin/env bash
# Pull a snapshot of MAYSL site analytics from the GA4 Data API.
#
# Usage:  ./analytics/pull.sh [YYYY-MM-DD]      (default start: 2022-01-01)
#
# Requires ADC with the analytics and Search Console scopes:
#   gcloud auth application-default login \
#     --scopes=https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/webmasters.readonly,https://www.googleapis.com/auth/cloud-platform
#
# The Search Console pull also needs the API enabled once:
#   gcloud services enable searchconsole.googleapis.com --project maysl-analytics-20260823
set -euo pipefail

PROPERTY=330581274                      # GA4 property (numeric, not G-3YQ3FTWMRY)
GSC_SITE="sc-domain:maysl.soccer"       # Search Console domain property (DNS-verified)
QUOTA_PROJECT=maysl-analytics-20260823  # GCP project for API quota; holds no data
START="${1:-2022-01-01}"
OUT="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y-%m-%d)"

TOKEN="$(gcloud auth application-default print-access-token 2>/dev/null || true)"
if [ "${#TOKEN}" -lt 50 ]; then
  echo "No ADC token. Run the gcloud auth command in the header comment." >&2
  exit 1
fi

api() {
  curl -s -X POST \
    "https://analyticsdata.googleapis.com/v1beta/properties/$PROPERTY:runReport" \
    -H "Authorization: Bearer $TOKEN" \
    -H "x-goog-user-project: $QUOTA_PROJECT" \
    -H "Content-Type: application/json" \
    -d "$1"
}

# Views per page, plus how many readers hit the 90% scroll event. The ratio is
# the read-through number the answer-box work was meant to move.
api '{"dateRanges":[{"startDate":"'"$START"'","endDate":"today"}],
      "dimensions":[{"name":"pagePath"},{"name":"eventName"}],
      "metrics":[{"name":"eventCount"}],
      "dimensionFilter":{"filter":{"fieldName":"eventName",
        "inListFilter":{"values":["page_view","scroll"]}}},
      "limit":2000}' \
| python3 -c '
import json,sys,collections,re
d=collections.defaultdict(collections.Counter)
for r in json.load(sys.stdin).get("rows",[]):
    p=re.sub(r"/{2,}","/",r["dimensionValues"][0]["value"])
    d[p][r["dimensionValues"][1]["value"]]+=int(r["metricValues"][0]["value"])
print("path\tviews\treached_90pct\tread_through_pct")
for p,c in sorted(d.items(), key=lambda kv:-kv[1]["page_view"]):
    v,s=c["page_view"],c["scroll"]
    if v: print(f"{p}\t{v}\t{s}\t{round(100*s/v)}")
' > "$OUT/$STAMP-read-through.tsv"

# Views per page per month, for seasonal phase comparisons.
api '{"dateRanges":[{"startDate":"'"$START"'","endDate":"today"}],
      "dimensions":[{"name":"yearMonth"},{"name":"pagePath"}],
      "metrics":[{"name":"screenPageViews"}],
      "limit":50000}' \
| python3 -c '
import json,sys,re
print("month\tpath\tviews")
for r in json.load(sys.stdin).get("rows",[]):
    m=r["dimensionValues"][0]["value"]
    p=re.sub(r"/{2,}","/",r["dimensionValues"][1]["value"])
    v=r["metricValues"][0]["value"]
    print(m+"\t"+p+"\t"+v)
' > "$OUT/$STAMP-pages-by-month.tsv"

# ---------------------------------------------------------------------------
# Search Console: the search queries themselves. GA4 does not report these --
# it can only say a session came from organic search, not what was typed.
# Note GSC keeps 16 months and only has data from after verification, so the
# window here is shorter than the GA4 one above.
# ---------------------------------------------------------------------------
gsc() {
  curl -s -X POST \
    "https://www.googleapis.com/webmasters/v3/sites/$(printf %s "$GSC_SITE" | sed 's/:/%3A/')/searchAnalytics/query" \
    -H "Authorization: Bearer $TOKEN" \
    -H "x-goog-user-project: $QUOTA_PROJECT" \
    -H "Content-Type: application/json" \
    -d "$1"
}

# GSC rejects "today" as an endDate, so both ends are explicit dates.
GSC_START="$(date -v-16m +%Y-%m-%d 2>/dev/null || date -d '16 months ago' +%Y-%m-%d)"

to_tsv() {
  python3 -c '
import json,sys
key=sys.argv[1]
d=json.load(sys.stdin)
if "error" in d:
    sys.stderr.write("  Search Console: " + d["error"].get("message","error") + "\n"); sys.exit(0)
print(key+"\tclicks\timpressions\tctr_pct\tavg_position")
for r in d.get("rows",[]):
    # pulled into locals rather than indexed inside an f-string: nested quotes
    # inside a single-quoted shell heredoc are a syntax error
    clicks = int(r["clicks"]); impr = int(r["impressions"])
    ctr = r["ctr"] * 100; pos = r["position"]
    print("\t".join([r["keys"][0], str(clicks), str(impr),
                     "%.1f" % ctr, "%.1f" % pos]))
' "$1"
}

gsc '{"startDate":"'"$GSC_START"'","endDate":"'"$STAMP"'","dimensions":["query"],"rowLimit":500}' \
  | to_tsv query > "$OUT/$STAMP-search-queries.tsv"

gsc '{"startDate":"'"$GSC_START"'","endDate":"'"$STAMP"'","dimensions":["page"],"rowLimit":500}' \
  | to_tsv page > "$OUT/$STAMP-search-pages.tsv"

echo "Wrote:"
ls -1 "$OUT/$STAMP"-*.tsv
