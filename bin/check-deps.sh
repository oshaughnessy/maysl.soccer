#!/usr/bin/env bash
# Report which command-line tools the scripts in this repo want, and how to get
# the missing ones. Checks only -- it never installs anything.
set -uo pipefail

# tool | brew formula | what breaks without it
TOOLS=(
  "bundle|ruby|everything: make build, serve, check"
  "python3|python|analytics/pull.sh, bin/check-site.sh"
  "curl|curl|analytics/pull.sh, the site checks"
  "pdftotext|poppler|make calendar -- falls back to a worse built-in reader"
  "yamllint|yamllint|make lint"
  "jq|jq|ad-hoc poking at the GA4 and Search Console JSON"
  "gcloud|--cask google-cloud-sdk|make analytics (GA4 + Search Console)"
)

missing=()
printf '%-12s %-9s %s\n' TOOL STATUS "NEEDED FOR"
for row in "${TOOLS[@]}"; do
  IFS='|' read -r tool formula why <<< "$row"
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%-12s %-9s %s\n' "$tool" "ok" "$why"
  else
    printf '%-12s %-9s %s\n' "$tool" "MISSING" "$why"
    missing+=("$formula")
  fi
done

echo
if [ ${#missing[@]} -eq 0 ]; then
  echo "All present."
else
  echo "Install the missing ones with:"
  echo "  brew install ${missing[*]}"
fi

# Auth is separate from installation: gcloud can be present but not logged in,
# and ADC is a different credential from the CLI's own.
if command -v gcloud >/dev/null 2>&1; then
  echo
  if [ -n "$(gcloud auth application-default print-access-token 2>/dev/null)" ]; then
    echo "ADC: ok (make analytics will work)"
  else
    echo "ADC: not authenticated. make analytics needs:"
    echo "  gcloud auth application-default login \\"
    echo "    --scopes=https://www.googleapis.com/auth/analytics.readonly,\\"
    echo "https://www.googleapis.com/auth/webmasters.readonly,\\"
    echo "https://www.googleapis.com/auth/cloud-platform"
  fi
fi
