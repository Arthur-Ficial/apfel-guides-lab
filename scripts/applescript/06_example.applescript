-- Real-world mini example: summarize a path from argv in one paragraph.
-- AppleScript cannot read stdin from `do shell script`, so pass a file path on argv.
-- Usage: osascript 06_example.applescript /path/to/file.txt
on run argv
  if (count of argv) < 1 then
    error "usage: osascript 06_example.applescript <path-to-file>"
  end if
  set filePath to item 1 of argv
  set cmd to "test -f " & quoted form of filePath & " && " & ¬
    "text=$(cat " & quoted form of filePath & "); " & ¬
    "payload=$(jq -n --arg text \"$text\" '{model:\"apple-foundationmodel\", messages:[{role:\"system\",content:\"You are a concise summarizer. Reply with one short paragraph.\"},{role:\"user\",content:(\"Summarize:\\n\\n\" + $text)}], max_tokens:150}'); " & ¬
    "curl -sS http://localhost:11434/v1/chat/completions -H 'Content-Type: application/json' -d \"$payload\" | jq -r '.choices[0].message.content'"
  return do shell script cmd
end run
