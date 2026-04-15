#!/usr/bin/env bash
# Real-world mini example: summarize text from stdin in one paragraph.
set -euo pipefail

text=$(cat)
if [[ -z "$text" ]]; then
  echo "usage: cat file.txt | bash 06_example.sh" >&2
  exit 1
fi

payload=$(jq -n --arg text "$text" '{
  model: "apple-foundationmodel",
  messages: [
    {role:"system", content:"You are a concise summarizer. Reply with one short paragraph."},
    {role:"user", content: ("Summarize:\n\n" + $text)}
  ],
  max_tokens: 150
}')

curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" -d "$payload" \
  | jq -r '.choices[0].message.content'
