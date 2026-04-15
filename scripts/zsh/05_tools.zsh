#!/bin/zsh
# Tool calling - same raw curl round-trip as Bash, but zsh-flavored.
emulate -L zsh
setopt err_exit pipe_fail no_unset

local tools='[{
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

local first
first=$(jq -n --argjson tools "$tools" '{
  model:"apple-foundationmodel",
  messages:[{role:"user", content:"What is the temperature in Vienna right now?"}],
  tools:$tools,
  max_tokens:256
}' | curl -sS http://localhost:11434/v1/chat/completions \
       -H "Content-Type: application/json" -d @-)

local msg=$(jq -c '.choices[0].message' <<<"$first")
local calls=$(jq -c '.tool_calls // []' <<<"$msg")

if (( $(jq 'length' <<<"$calls") > 0 )); then
  local call=$(jq -c '.[0]' <<<"$calls")
  local city=$(jq -r '.function.arguments | fromjson | .city' <<<"$call")
  local -A fake=(Vienna 14 Cupertino 19 Tokyo 11)
  local temp=${fake[$city]:-15}
  local tool_result=$(jq -cn --arg c "$city" --argjson t "$temp" '{city:$c, temp_c:$t}')
  local tool_msg=$(jq -cn --arg id "$(jq -r '.id' <<<"$call")" --arg content "$tool_result" \
    '{role:"tool", tool_call_id:$id, content:$content}')

  local final_payload=$(jq -n --argjson msg "$msg" --argjson tool "$tool_msg" '{
    model:"apple-foundationmodel",
    messages:[
      {role:"user", content:"What is the temperature in Vienna right now?"},
      $msg,
      $tool
    ],
    max_tokens:120
  }')

  curl -sS http://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" -d "$final_payload" \
    | jq -r '.choices[0].message.content'
else
  jq -r '.content' <<<"$msg"
fi
