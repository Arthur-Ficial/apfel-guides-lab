-- Streaming chat completion. AppleScript has no native streaming, so we drive curl
-- and let the shell pipeline parse the SSE stream. Output arrives token-by-token
-- on stdout, then returns to AppleScript as the final string.
set shellCmd to "curl -sS -N http://localhost:11434/v1/chat/completions " & ¬
    "-H 'Content-Type: application/json' " & ¬
    "-d '{\"model\":\"apple-foundationmodel\",\"messages\":[{\"role\":\"user\",\"content\":\"List three Apple silicon chips, one per line.\"}],\"max_tokens\":80,\"stream\":true}' " & ¬
    "| while IFS= read -r line; do " & ¬
    "    line=\"${line#data: }\"; " & ¬
    "    [ -z \"$line\" ] || [ \"$line\" = \"[DONE]\" ] && continue; " & ¬
    "    content=$(printf '%s' \"$line\" | jq -r '.choices[0].delta.content // empty' 2>/dev/null || true); " & ¬
    "    [ -n \"$content\" ] && printf '%s' \"$content\"; " & ¬
    "  done; echo"
return do shell script shellCmd
