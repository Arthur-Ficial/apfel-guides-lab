#!/bin/zsh
# Streaming chat completion using zsh `read` + parameter expansion.
emulate -L zsh
setopt err_exit pipe_fail no_unset

curl -sS -N http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"apple-foundationmodel","messages":[{"role":"user","content":"List three Apple silicon chips, one per line."}],"max_tokens":80,"stream":true}' \
  | while IFS= read -r line; do
      line=${line#data: }
      [[ -z $line || $line == "[DONE]" ]] && continue
      # Extract delta.content without invoking a subshell-per-chunk when possible:
      local piece
      piece=$(print -r -- "$line" | jq -r '.choices[0].delta.content // empty' 2>/dev/null) || true
      [[ -n $piece ]] && print -rn -- "$piece"
    done
print
