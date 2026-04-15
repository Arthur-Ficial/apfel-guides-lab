#!/bin/zsh
# Real-world mini example: summarize text from stdin in one paragraph.
emulate -L zsh
setopt err_exit pipe_fail no_unset

local text=$(cat)
if [[ -z $text ]]; then
  print -u 2 -- "usage: cat file.txt | zsh 06_example.zsh"
  exit 1
fi

local payload=$(jq -n --arg text "$text" '{
  model:"apple-foundationmodel",
  messages:[
    {role:"system", content:"You are a concise summarizer. Reply with one short paragraph."},
    {role:"user", content: ("Summarize:\n\n" + $text)}
  ],
  max_tokens:150
}')

curl -sS http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" -d "$payload" \
  | jq -r '.choices[0].message.content'
