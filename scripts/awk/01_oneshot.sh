#!/usr/bin/env bash
# AWK-flavored one-shot: AWK builds the JSON payload, curl ships it, AWK extracts
# the content. Pure AWK has no HTTP; the Unix convention is to pair awk with curl.
set -euo pipefail

PROMPT="In one sentence, what is the Swift programming language?"
PAYLOAD=$(awk -v prompt="$PROMPT" 'BEGIN {
  gsub(/"/, "\\\"", prompt)
  printf "{\"model\":\"apple-foundationmodel\",\"messages\":[{\"role\":\"user\",\"content\":\"%s\"}],\"max_tokens\":80}", prompt
}')

curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" -d "$PAYLOAD" \
  | awk 'BEGIN { RS="\"content\" :" } NR==2 {
      # Grab the JSON string value after "content" :
      match($0, /"([^"\\]|\\.)*"/)
      s = substr($0, RSTART+1, RLENGTH-2)
      gsub(/\\n/, "\n", s); gsub(/\\"/, "\"", s); gsub(/\\\\/, "\\", s)
      print s
    }'
