#!/usr/bin/env bash
# JSON mode - request structured output, strip any markdown fences, validate.
set -euo pipefail

raw=$(curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "apple-foundationmodel",
    "messages": [{
      "role": "user",
      "content": "Return JSON with fields chip, year, cores. Describe the Apple M1 chip. Return ONLY JSON."
    }],
    "response_format": {"type": "json_object"},
    "max_tokens": 120
  }' \
  | jq -r '.choices[0].message.content')

# Strip optional ```json ... ``` fences some servers emit.
raw=$(printf '%s' "$raw" | sed -E 's/^```(json)?//; s/```$//' | tr -d '\r')

printf '%s' "$raw" | jq '.'
