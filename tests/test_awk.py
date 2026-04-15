"""AWK scripts - each is a bash driver that uses awk for parsing."""
import json

from tests.helpers import (
    REPO_ROOT,
    assert_model_output_ok,
    capture_output,
    run_script,
    run_script_retrying,
    script_path,
)

AWK_DIR = REPO_ROOT / "scripts" / "awk"


def _run(script: str, stdin: str | None = None):
    return run_script(["bash", str(script_path("awk", script))], cwd=AWK_DIR, stdin=stdin)


def test_oneshot(capture_mode):
    r = _run("01_oneshot.sh")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("awk", "01_oneshot.sh", r.stdout)


def test_stream(capture_mode):
    r = _run("02_stream.sh")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("awk", "02_stream.sh", r.stdout)


def test_json(capture_mode):
    r = _run("03_json.sh")
    assert_model_output_ok(r)
    assert isinstance(json.loads(r.stdout), dict)
    if capture_mode:
        capture_output("awk", "03_json.sh", r.stdout)


def test_errors(capture_mode):
    r = _run("04_errors.sh")
    assert_model_output_ok(r)
    assert "501" in r.stdout
    if capture_mode:
        capture_output("awk", "04_errors.sh", r.stdout)


def test_tools(capture_mode):
    def ok(r):
        return r.returncode == 0 and any(
            w in r.stdout.lower() for w in ("vienna", "14", "temperature", "celsius")
        )
    r = run_script_retrying(
        ["bash", str(script_path("awk", "05_tools.sh"))],
        cwd=AWK_DIR, attempts=3, predicate=ok,
    )
    assert ok(r), f"tool-calling did not produce weather answer after retries:\n{r.stdout}"
    if capture_mode:
        capture_output("awk", "05_tools.sh", r.stdout)


FIXTURE_TEXT = (
    "The Apple M1 chip, released in November 2020, was Apple's first ARM-based "
    "system-on-a-chip for Mac computers. It uses an 8-core CPU with four performance "
    "and four efficiency cores, plus an integrated GPU with up to 8 cores. The chip "
    "unified CPU, GPU, memory, and neural engine on a single die, delivering significant "
    "performance-per-watt improvements over the Intel chips it replaced."
)


def test_example(capture_mode):
    r = _run("06_example.sh", stdin=FIXTURE_TEXT)
    assert_model_output_ok(r, min_chars=50)
    if capture_mode:
        capture_output("awk", "06_example.sh", r.stdout)
