#!/usr/bin/env bash
# AWK-flavored streaming: curl pipes SSE into awk, which parses each `data: {...}`
# line and prints the delta.content as it arrives.
set -euo pipefail

curl -sS -N http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"apple-foundationmodel","messages":[{"role":"user","content":"List three Apple silicon chips, one per line."}],"max_tokens":80,"stream":true}' \
  | awk '
      /^data: / {
        json = substr($0, 7)
        if (json == "[DONE]" || json == "") next
        # extract "content":"..."
        if (match(json, /"content":"([^"\\]|\\.)*"/)) {
          s = substr(json, RSTART + 11, RLENGTH - 12)
          gsub(/\\n/, "\n", s); gsub(/\\"/, "\"", s); gsub(/\\\\/, "\\", s)
          printf "%s", s
          fflush()
        }
      }
      END { print "" }
    '
