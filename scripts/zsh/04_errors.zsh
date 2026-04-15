#!/bin/zsh
# Error handling - capture HTTP status and body, print a friendly message on >= 400.
emulate -L zsh
setopt err_exit pipe_fail no_unset

local tmp=$(mktemp)
local http_status
http_status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  http://localhost:11434/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model":"apple-foundationmodel","input":"apfel runs 100% on-device."}')

if (( http_status >= 400 )); then
  local msg=$(jq -r '.error.message // empty' "$tmp" 2>/dev/null) || true
  print -r -- "Got expected error: HTTP ${http_status} - ${msg:-see response}"
else
  print -r -- "unexpected success: HTTP ${http_status}"
  cat "$tmp"
fi
rm -f "$tmp"
