"""Swift scripting scripts - run each via `swift` against live apfel --serve."""
import json

from tests.helpers import (
    REPO_ROOT,
    assert_model_output_ok,
    capture_output,
    run_script,
    run_script_retrying,
    script_path,
)

SW_DIR = REPO_ROOT / "scripts" / "swift-scripting"


def _run(script: str, stdin: str | None = None, retry: bool = False):
    argv = ["swift", str(script_path("swift-scripting", script))]
    if retry:
        return run_script_retrying(argv, cwd=SW_DIR, stdin=stdin, timeout=180)
    return run_script(argv, cwd=SW_DIR, stdin=stdin, timeout=180)


def test_oneshot(capture_mode):
    r = _run("01_oneshot.swift")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("swift-scripting", "01_oneshot.swift", r.stdout)


def test_stream(capture_mode):
    r = _run("02_stream.swift")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("swift-scripting", "02_stream.swift", r.stdout)


def test_json(capture_mode):
    r = _run("03_json.swift")
    assert_model_output_ok(r)
    assert isinstance(json.loads(r.stdout), dict)
    if capture_mode:
        capture_output("swift-scripting", "03_json.swift", r.stdout)


def test_errors(capture_mode):
    r = _run("04_errors.swift")
    assert_model_output_ok(r)
    assert "501" in r.stdout
    if capture_mode:
        capture_output("swift-scripting", "04_errors.swift", r.stdout)


def test_tools(capture_mode):
    # LLMs occasionally refuse tool calls non-deterministically - retry once.
    r = _run("05_tools.swift", retry=True)
    if r.returncode != 0 or not any(w in r.stdout.lower() for w in ("vienna", "14", "temperature", "celsius")):
        r = _run("05_tools.swift")  # one more try
    assert_model_output_ok(r)
    assert any(w in r.stdout.lower() for w in ("vienna", "14", "temperature", "celsius"))
    if capture_mode:
        capture_output("swift-scripting", "05_tools.swift", r.stdout)


FIXTURE_TEXT = (
    "The Apple M1 chip, released in November 2020, was Apple's first ARM-based "
    "system-on-a-chip for Mac computers. It uses an 8-core CPU with four performance "
    "and four efficiency cores, plus an integrated GPU with up to 8 cores. The chip "
    "unified CPU, GPU, memory, and neural engine on a single die, delivering significant "
    "performance-per-watt improvements over the Intel chips it replaced."
)


def test_example(capture_mode):
    r = _run("06_example.swift", stdin=FIXTURE_TEXT)
    assert_model_output_ok(r, min_chars=50)
    if capture_mode:
        capture_output("swift-scripting", "06_example.swift", r.stdout)
