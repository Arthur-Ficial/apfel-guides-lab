#!/usr/bin/env bash
# AWK + curl for JSON mode. AWK is not a JSON parser - for real validation we
# hand the stripped content to jq. This is the honest, idiomatic AWK-for-text pattern.
set -euo pipefail

PAYLOAD='{"model":"apple-foundationmodel","messages":[{"role":"user","content":"Return JSON with fields chip, year, cores. Describe the Apple M1 chip. Return ONLY JSON."}],"response_format":{"type":"json_object"},"max_tokens":120}'

curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" -d "$PAYLOAD" \
  | awk 'BEGIN { RS="\"content\" :" } NR==2 {
      match($0, /"([^"\\]|\\.)*"/)
      s = substr($0, RSTART+1, RLENGTH-2)
      gsub(/\\n/, "\n", s); gsub(/\\"/, "\"", s); gsub(/\\\\/, "\\", s)
      print s
    }' \
  | sed -E 's/^```(json)?//; s/```$//' \
  | jq '.'
