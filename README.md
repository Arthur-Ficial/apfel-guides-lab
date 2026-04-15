# apfel-guides-lab

Runnable proof for the **[apfel](https://github.com/Arthur-Ficial/apfel) language guides**.

Every code block in every `docs/guides/*.md` file on the apfel repo was run here first against a live `apfel --serve`, and the captured output was pasted into the guide byte-for-byte.

## Layout

```
scripts/<language>/   # idiomatic scripts, 6 per language
tests/test_<lang>.py  # pytest subprocess-runs each script
conftest.py           # boots apfel --serve on :11434, polls /health
outputs/<lang>/       # committed real stdout captures (source of truth for guides)
```

## Languages covered

Python, Node.js, Ruby, PHP, Bash/curl, Zsh, AppleScript, Swift scripting, Perl, AWK.

## Run everything

```bash
make test        # run all language tests against live apfel --serve
make capture     # re-run + update outputs/
make test-python # single language
```

## Prerequisites

- macOS 26+, Apple Silicon, Apple Intelligence enabled
- `brew install apfel` (or build from source)
- Language toolchains (Python 3, Node 20+, Ruby, PHP, Perl, Swift) - most ship with macOS
- `uv` for Python, `composer` for PHP, `bundler` for Ruby, `npm` for Node

The harness auto-starts `apfel --serve` on port 11434. If you already have one running there, stop it first.

## Why this exists

The guides on the apfel repo must be empirically correct. Lying docs are worse than no docs. This repo is the proof.

## Links

- **Main project:** [Arthur-Ficial/apfel](https://github.com/Arthur-Ficial/apfel)
- **Guides:** [apfel/docs/guides/](https://github.com/Arthur-Ficial/apfel/tree/main/docs/guides)
- **Landing page:** [apfel.franzai.com](https://apfel.franzai.com)
