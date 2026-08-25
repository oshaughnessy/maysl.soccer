#!/usr/bin/env bash
# Pull a snapshot of MAYSL site analytics from the GA4 Data API.
#
# Usage:  ./analytics/pull.sh [YYYY-MM-DD]      (default start: 2022-01-01)
#
# Requires ADC with the analytics scope:
#   gcloud auth application-default login \
#     --scopes=https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/cloud-platform
set -euo pipefail

PROPERTY=330581274                      # GA4 property (numeric, not G-3YQ3FTWMRY)
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

echo "Wrote:"
ls -1 "$OUT/$STAMP"-*.tsv
