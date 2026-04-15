-- Tool calling is not idiomatic in pure AppleScript - JSON escaping becomes
-- unreadable. For production tool-calling with apfel, use Python or Node.
-- AppleScript's correct pattern here is to delegate complex shell work to a
-- script file. We re-use the Bash tool-calling script from this repo.
set scriptPath to POSIX path of ((path to me as text) & "::") & "../bash-curl/05_tools.sh"
return do shell script "bash " & quoted form of scriptPath
