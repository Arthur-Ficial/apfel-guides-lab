#!/usr/bin/env bash
# One-shot chat completion via curl + jq.
set -euo pipefail

curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "apple-foundationmodel",
    "messages": [{"role": "user", "content": "In one sentence, what is the Swift programming language?"}],
    "max_tokens": 80
  }' \
  | jq -r '.choices[0].message.content'
