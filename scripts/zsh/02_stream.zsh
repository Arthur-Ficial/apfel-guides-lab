#!/bin/zsh
# Streaming chat completion using zsh `read` + parameter expansion.
emulate -L zsh
setopt err_exit pipe_fail no_unset no_xtrace no_verbose

curl -sS -N http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"apple-foundationmodel","messages":[{"role":"user","content":"List three Apple silicon chips, one per line."}],"max_tokens":80,"stream":true}' \
  | while IFS= read -r line; do
      line=${line#data: }
      [[ -z $line || $line == "[DONE]" ]] && continue
      piece=$(print -r -- "$line" | jq -r '.choices[0].delta.content // empty' 2>/dev/null) || piece=
      [[ -n $piece ]] && print -rn -- "$piece"
    done
print
