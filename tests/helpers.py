"""Shared test helpers for subprocess-running language scripts."""
from __future__ import annotations

import subprocess
from pathlib import Path
from typing import Sequence

REPO_ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = REPO_ROOT / "scripts"
OUTPUTS = REPO_ROOT / "outputs"


def script_path(lang: str, filename: str) -> Path:
    p = SCRIPTS / lang / filename
    if not p.exists():
        raise FileNotFoundError(f"missing script: {p}")
    return p


def run_script(
    argv: Sequence[str],
    cwd: Path | None = None,
    stdin: str | None = None,
    timeout: int = 120,
    env_extra: dict | None = None,
) -> subprocess.CompletedProcess:
    import os
    env = os.environ.copy()
    env.setdefault("APFEL_BASE_URL", "http://localhost:11434/v1")
    env.setdefault("APFEL_API_KEY", "not-needed")
    if env_extra:
        env.update(env_extra)
    return subprocess.run(
        list(argv),
        cwd=cwd,
        input=stdin,
        capture_output=True,
        text=True,
        timeout=timeout,
        env=env,
    )


def assert_model_output_ok(result: subprocess.CompletedProcess, min_chars: int = 5):
    assert result.returncode == 0, (
        f"script failed (exit {result.returncode})\n"
        f"STDOUT:\n{result.stdout}\n"
        f"STDERR:\n{result.stderr}"
    )
    out = result.stdout.strip()
    assert len(out) >= min_chars, f"stdout too short ({len(out)} chars):\n{out!r}"


def capture_output(lang: str, filename: str, stdout: str):
    d = OUTPUTS / lang
    d.mkdir(parents=True, exist_ok=True)
    base = filename.rsplit(".", 1)[0]
    (d / f"{base}.txt").write_text(stdout)
