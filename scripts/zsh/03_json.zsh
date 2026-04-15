#!/bin/zsh
# JSON mode - ask for a JSON object, strip any markdown fences, pretty-print.
emulate -L zsh
setopt err_exit pipe_fail no_unset

local raw
raw=$(curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model":"apple-foundationmodel",
    "messages":[{"role":"user","content":"Return JSON with fields chip, year, cores. Describe the Apple M1 chip. Return ONLY JSON."}],
    "response_format":{"type":"json_object"},
    "max_tokens":120
  }' | jq -r '.choices[0].message.content')

# zsh parameter expansion strips ```json ... ``` fences without calling sed.
raw=${raw#\`\`\`json}
raw=${raw#\`\`\`}
raw=${raw%\`\`\`}
raw=${raw//$'\r'/}

print -r -- "$raw" | jq '.'
