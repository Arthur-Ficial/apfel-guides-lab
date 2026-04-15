-- JSON mode - drive curl from AppleScript, strip any markdown fences, pretty-print.
set payload to "{\"model\":\"apple-foundationmodel\",\"messages\":[{\"role\":\"user\",\"content\":\"Return JSON with fields chip, year, cores. Describe the Apple M1 chip. Return ONLY JSON.\"}],\"response_format\":{\"type\":\"json_object\"},\"max_tokens\":120}"
set cmd to "curl -sS http://localhost:11434/v1/chat/completions -H 'Content-Type: application/json' -d " & quoted form of payload & " | jq -r '.choices[0].message.content' | sed -E 's/^```(json)?//; s/```$//' | tr -d '\\r' | jq '.'"
return do shell script cmd
