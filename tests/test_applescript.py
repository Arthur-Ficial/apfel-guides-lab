"""AppleScript scripts - run each via osascript against live apfel --serve."""
import json
import tempfile
from pathlib import Path

from tests.helpers import (
    REPO_ROOT,
    assert_model_output_ok,
    capture_output,
    run_script,
    script_path,
)

AS_DIR = REPO_ROOT / "scripts" / "applescript"


def _run(script: str, extra_args: list[str] | None = None):
    argv = ["osascript", str(script_path("applescript", script))]
    if extra_args:
        argv += extra_args
    return run_script(argv, cwd=AS_DIR)


def test_oneshot(capture_mode):
    r = _run("01_oneshot.applescript")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("applescript", "01_oneshot.applescript", r.stdout)


def test_stream(capture_mode):
    r = _run("02_stream.applescript")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("applescript", "02_stream.applescript", r.stdout)


def test_json(capture_mode):
    r = _run("03_json.applescript")
    assert_model_output_ok(r)
    # AppleScript `do shell script` collapses newlines; JSON is still valid.
    assert isinstance(json.loads(r.stdout), dict)
    if capture_mode:
        capture_output("applescript", "03_json.applescript", r.stdout)


def test_errors(capture_mode):
    r = _run("04_errors.applescript")
    assert_model_output_ok(r)
    assert "501" in r.stdout
    if capture_mode:
        capture_output("applescript", "04_errors.applescript", r.stdout)


def test_tools(capture_mode):
    r = _run("05_tools.applescript")
    assert_model_output_ok(r)
    assert any(w in r.stdout.lower() for w in ("vienna", "14", "temperature", "celsius"))
    if capture_mode:
        capture_output("applescript", "05_tools.applescript", r.stdout)


FIXTURE_TEXT = (
    "The Apple M1 chip, released in November 2020, was Apple's first ARM-based "
    "system-on-a-chip for Mac computers. It uses an 8-core CPU with four performance "
    "and four efficiency cores, plus an integrated GPU with up to 8 cores. The chip "
    "unified CPU, GPU, memory, and neural engine on a single die, delivering significant "
    "performance-per-watt improvements over the Intel chips it replaced."
)


def test_example(capture_mode):
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as tf:
        tf.write(FIXTURE_TEXT)
        path = tf.name
    try:
        r = _run("06_example.applescript", extra_args=[path])
        assert_model_output_ok(r, min_chars=50)
        if capture_mode:
            capture_output("applescript", "06_example.applescript", r.stdout)
    finally:
        Path(path).unlink(missing_ok=True)
