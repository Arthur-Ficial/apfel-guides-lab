"""Session-scoped apfel --serve fixture.

Boots `apfel --serve --port 11434` for the test session and tears it down at exit.
If a server is ALREADY running on 11434 (detected via /health 200), we reuse it
and skip the boot/kill cycle. Lets developers `apfel --serve` in one terminal
and `pytest` in another without port conflicts.
"""
from __future__ import annotations

import os
import shutil
import signal
import subprocess
import time
from pathlib import Path

import pytest
import requests

APFEL_PORT = 11434
APFEL_URL = f"http://localhost:{APFEL_PORT}"
BOOT_TIMEOUT = 30


def _health_ok() -> bool:
    try:
        r = requests.get(f"{APFEL_URL}/health", timeout=2)
        return r.status_code == 200
    except requests.RequestException:
        return False


@pytest.fixture(scope="session", autouse=True)
def apfel_server():
    """Ensure apfel --serve is reachable on :11434 for the whole test session."""
    if _health_ok():
        # Someone else is already serving - reuse it.
        yield APFEL_URL
        return

    binary = shutil.which("apfel")
    if not binary:
        pytest.skip("apfel not on PATH - install via `brew install apfel` or `make install` in the apfel repo")

    proc = subprocess.Popen(
        [binary, "--serve", "--port", str(APFEL_PORT)],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    deadline = time.time() + BOOT_TIMEOUT
    while time.time() < deadline:
        if _health_ok():
            break
        if proc.poll() is not None:
            out = proc.stdout.read().decode("utf-8", errors="replace") if proc.stdout else ""
            raise RuntimeError(f"apfel --serve exited early:\n{out}")
        time.sleep(0.5)
    else:
        proc.terminate()
        raise RuntimeError(f"apfel --serve did not become healthy within {BOOT_TIMEOUT}s")

    try:
        yield APFEL_URL
    finally:
        proc.send_signal(signal.SIGTERM)
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            proc.kill()


@pytest.fixture
def apfel_url(apfel_server) -> str:
    return apfel_server


@pytest.fixture
def capture_mode() -> bool:
    return os.environ.get("CAPTURE") == "1"


@pytest.fixture
def outputs_dir() -> Path:
    d = Path(__file__).parent / "outputs"
    d.mkdir(exist_ok=True)
    return d
