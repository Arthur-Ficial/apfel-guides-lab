#!/usr/bin/env bash
# Real-world mini example: AWK pre-processes stdin (strips leading/trailing blanks,
# squeezes repeated spaces), then hands the text to apfel via curl for summary.
set -euo pipefail

# AWK does the text cleanup it is actually good at:
cleaned=$(awk '
  { sub(/^[[:space:]]+/, ""); sub(/[[:space:]]+$/, ""); gsub(/[[:space:]]+/, " ") }
  { print }
' | awk 'NF')

if [[ -z "$cleaned" ]]; then
  echo "usage: cat file.txt | bash 06_example.sh" >&2
  exit 1
fi

# Build payload with jq (proper JSON escaping for the summarize prompt).
payload=$(jq -n --arg text "$cleaned" '{
  model:"apple-foundationmodel",
  messages:[
    {role:"system", content:"You are a concise summarizer. Reply with one short paragraph."},
    {role:"user", content:("Summarize:\n\n" + $text)}
  ],
  max_tokens:150
}')

curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" -d "$payload" \
  | awk 'BEGIN { RS="\"content\" :" } NR==2 {
      match($0, /"([^"\\]|\\.)*"/)
      s = substr($0, RSTART+1, RLENGTH-2)
      gsub(/\\n/, "\n", s); gsub(/\\"/, "\"", s); gsub(/\\\\/, "\\", s)
      print s
    }'
