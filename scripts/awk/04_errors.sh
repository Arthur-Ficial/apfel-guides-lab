#!/usr/bin/env bash
# Error handling - capture HTTP status, use awk to extract .error.message from the body.
set -euo pipefail

tmp=$(mktemp)
status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  http://localhost:11434/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model":"apple-foundationmodel","input":"apfel runs 100% on-device."}')

if [[ "$status" -ge 400 ]]; then
  msg=$(awk 'BEGIN { RS="\"message\" :" } NR==2 {
    match($0, /"([^"\\]|\\.)*"/)
    s = substr($0, RSTART+1, RLENGTH-2)
    gsub(/\\"/, "\"", s); gsub(/\\\\/, "\\", s)
    print s
  }' "$tmp")
  echo "Got expected error: HTTP $status - ${msg:-see response}"
else
  echo "unexpected success: HTTP $status"
  cat "$tmp"
fi
rm -f "$tmp"
