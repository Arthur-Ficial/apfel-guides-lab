#!/bin/zsh
# One-shot chat completion via curl + jq, using zsh idioms.
emulate -L zsh
setopt err_exit pipe_fail no_unset

local url="http://localhost:11434/v1/chat/completions"
local -A req=(
  model "apple-foundationmodel"
  prompt "In one sentence, what is the Swift programming language?"
)

local payload="$(jq -cn --arg m "$req[model]" --arg p "$req[prompt]" \
  '{model:$m, messages:[{role:"user", content:$p}], max_tokens:80}')"

curl -sS "$url" -H "Content-Type: application/json" -d "$payload" \
  | jq -r '.choices[0].message.content'
