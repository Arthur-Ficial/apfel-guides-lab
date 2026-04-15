"""Perl scripts - run each via `perl` against live apfel --serve."""
import json

from tests.helpers import (
    REPO_ROOT,
    assert_model_output_ok,
    capture_output,
    run_script,
    run_script_retrying,
    script_path,
)

PL_DIR = REPO_ROOT / "scripts" / "perl"


def _run(script: str, stdin: str | None = None):
    return run_script(["perl", str(script_path("perl", script))], cwd=PL_DIR, stdin=stdin)


def test_oneshot(capture_mode):
    r = _run("01_oneshot.pl")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("perl", "01_oneshot.pl", r.stdout)


def test_stream(capture_mode):
    r = _run("02_stream.pl")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("perl", "02_stream.pl", r.stdout)


def test_json(capture_mode):
    r = _run("03_json.pl")
    assert_model_output_ok(r)
    assert isinstance(json.loads(r.stdout), dict)
    if capture_mode:
        capture_output("perl", "03_json.pl", r.stdout)


def test_errors(capture_mode):
    r = _run("04_errors.pl")
    assert_model_output_ok(r)
    assert "501" in r.stdout
    if capture_mode:
        capture_output("perl", "04_errors.pl", r.stdout)


def test_tools(capture_mode):
    # Tool calling can be flaky with small models; retry up to 3 times.
    def ok(r):
        return r.returncode == 0 and any(
            w in r.stdout.lower() for w in ("vienna", "14", "15", "temperature", "celsius")
        )
    r = run_script_retrying(
        ["perl", str(script_path("perl", "05_tools.pl"))],
        cwd=PL_DIR, attempts=3, predicate=ok,
    )
    assert ok(r), f"tool-calling did not produce weather answer after retries:\n{r.stdout}\n{r.stderr}"
    if capture_mode:
        capture_output("perl", "05_tools.pl", r.stdout)


FIXTURE_TEXT = (
    "The Apple M1 chip, released in November 2020, was Apple's first ARM-based "
    "system-on-a-chip for Mac computers. It uses an 8-core CPU with four performance "
    "and four efficiency cores, plus an integrated GPU with up to 8 cores. The chip "
    "unified CPU, GPU, memory, and neural engine on a single die, delivering significant "
    "performance-per-watt improvements over the Intel chips it replaced."
)


def test_example(capture_mode):
    r = _run("06_example.pl", stdin=FIXTURE_TEXT)
    assert_model_output_ok(r, min_chars=50)
    if capture_mode:
        capture_output("perl", "06_example.pl", r.stdout)
