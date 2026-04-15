#!/usr/bin/env bash
# Error handling - catch apfel's honest 501 for unsupported endpoints.
set -euo pipefail

tmp=$(mktemp)
http_status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  http://localhost:11434/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model":"apple-foundationmodel","input":"apfel runs 100% on-device."}')

if [[ "$http_status" -ge 400 ]]; then
  msg=$(jq -r '.error.message // empty' "$tmp" 2>/dev/null || true)
  echo "Got expected error: HTTP $http_status - ${msg:-see response}"
else
  echo "unexpected success: HTTP $http_status"
  cat "$tmp"
fi
rm -f "$tmp"
