#!/usr/bin/env bash
# Tool calling from AWK is not idiomatic - JSON round-tripping is outside AWK's
# sweet spot. The honest pattern for AWK scripts is to delegate tool-calling to
# jq/bash. We reuse the bash-curl tool-calling script.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
bash "$here/../bash-curl/05_tools.sh"
