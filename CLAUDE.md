# apfel-guides-lab - Project Instructions

## The Golden Goal

apfel-guides-lab is the runnable proof for the apfel language guides. Its one ultimate purpose: guarantee that every code block in every `docs/guides/*.md` on the apfel repo actually works, by running idiomatic scripts in 10 scripting languages (Python, Node.js, Ruby, PHP, Bash/curl, Zsh, AppleScript, Swift scripting, Perl, AWK) against a live `apfel --serve` and committing the real stdout to `outputs/` as the byte-for-byte source of truth for the guides. It IS a pytest harness plus per-language scripts and captured outputs - empirical, reproducible, honest. It is NOT a place to host the guides themselves, ship a library, add languages apfel does not document, or accept scripts whose output was hand-edited rather than captured from a real run. Lying docs are worse than no docs - this repo is the proof, nothing more.
