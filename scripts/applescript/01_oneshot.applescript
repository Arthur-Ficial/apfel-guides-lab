-- One-shot chat completion via `do shell script` + curl.
set payload to "{\"model\":\"apple-foundationmodel\",\"messages\":[{\"role\":\"user\",\"content\":\"In one sentence, what is the Swift programming language?\"}],\"max_tokens\":80}"
set response to do shell script "curl -sS http://localhost:11434/v1/chat/completions -H 'Content-Type: application/json' -d " & quoted form of payload & " | jq -r '.choices[0].message.content'"
return response
