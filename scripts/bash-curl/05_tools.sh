#!/usr/bin/env bash
# Tool calling - raw curl round-trip: model asks for a tool call, we answer, model replies.
set -euo pipefail

tools='[{
  "type":"function",
  "function":{
    "name":"get_weather",
    "description":"Get the current temperature in Celsius for a city.",
    "parameters":{
      "type":"object",
      "properties":{"city":{"type":"string","description":"City name"}},
      "required":["city"]
    }
  }
}]'

first=$(jq -n --argjson tools "$tools" '{
  model: "apple-foundationmodel",
  messages: [{role:"user", content:"What is the temperature in Vienna right now?"}],
  tools: $tools,
  max_tokens: 256
}' | curl -sS http://localhost:11434/v1/chat/completions \
       -H "Content-Type: application/json" -d @-)

msg=$(jq -c '.choices[0].message' <<<"$first")
calls=$(jq -c '.tool_calls // []' <<<"$msg")

if [[ "$(jq 'length' <<<"$calls")" -gt 0 ]]; then
  call=$(jq -c '.[0]' <<<"$calls")
  city=$(jq -r '.function.arguments | fromjson | .city' <<<"$call")
  case "$city" in
    Vienna)    temp=14 ;;
    Cupertino) temp=19 ;;
    Tokyo)     temp=11 ;;
    *)         temp=15 ;;
  esac
  tool_result=$(jq -cn --arg c "$city" --argjson t "$temp" '{city:$c, temp_c:$t}')
  tool_msg=$(jq -cn --arg id "$(jq -r '.id' <<<"$call")" --arg content "$tool_result" \
    '{role:"tool", tool_call_id:$id, content:$content}')

  final_payload=$(jq -n --argjson msg "$msg" --argjson tool "$tool_msg" '{
    model: "apple-foundationmodel",
    messages: [
      {role:"user", content:"What is the temperature in Vienna right now?"},
      $msg,
      $tool
    ],
    max_tokens: 120
  }')
  curl -sS http://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" -d "$final_payload" \
    | jq -r '.choices[0].message.content'
else
  jq -r '.content' <<<"$msg"
fi
