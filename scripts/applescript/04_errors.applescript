-- Error handling - capture HTTP status via curl -w, print friendly message on >= 400.
set cmd to "tmp=$(mktemp); status=$(curl -sS -o \"$tmp\" -w '%{http_code}' http://localhost:11434/v1/embeddings -H 'Content-Type: application/json' -d '{\"model\":\"apple-foundationmodel\",\"input\":\"apfel runs 100% on-device.\"}'); if [ \"$status\" -ge 400 ]; then msg=$(jq -r '.error.message // empty' \"$tmp\" 2>/dev/null || true); echo \"Got expected error: HTTP $status - ${msg:-see response}\"; else echo \"unexpected success: HTTP $status\"; cat \"$tmp\"; fi; rm -f \"$tmp\""
return do shell script cmd
