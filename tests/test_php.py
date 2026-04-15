"""PHP language scripts - run each against live apfel --serve."""
import json

from tests.helpers import (
    REPO_ROOT,
    assert_model_output_ok,
    capture_output,
    run_script,
    script_path,
)

PHP_DIR = REPO_ROOT / "scripts" / "php"


def _run(script: str, stdin: str | None = None):
    return run_script(["php", str(script_path("php", script))], cwd=PHP_DIR, stdin=stdin)


def test_oneshot(capture_mode):
    r = _run("01_oneshot.php")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("php", "01_oneshot.php", r.stdout)


def test_stream(capture_mode):
    r = _run("02_stream.php")
    assert_model_output_ok(r)
    assert "\n" in r.stdout
    if capture_mode:
        capture_output("php", "02_stream.php", r.stdout)


def test_json(capture_mode):
    r = _run("03_json.php")
    assert_model_output_ok(r)
    assert isinstance(json.loads(r.stdout), dict)
    if capture_mode:
        capture_output("php", "03_json.php", r.stdout)


def test_errors(capture_mode):
    r = _run("04_errors.php")
    assert_model_output_ok(r)
    assert "501" in r.stdout
    if capture_mode:
        capture_output("php", "04_errors.php", r.stdout)


def test_tools(capture_mode):
    r = _run("05_tools.php")
    assert_model_output_ok(r)
    assert any(w in r.stdout.lower() for w in ("vienna", "14", "temperature", "celsius"))
    if capture_mode:
        capture_output("php", "05_tools.php", r.stdout)


FIXTURE_TEXT = (
    "The Apple M1 chip, released in November 2020, was Apple's first ARM-based "
    "system-on-a-chip for Mac computers. It uses an 8-core CPU with four performance "
    "and four efficiency cores, plus an integrated GPU with up to 8 cores. The chip "
    "unified CPU, GPU, memory, and neural engine on a single die, delivering significant "
    "performance-per-watt improvements over the Intel chips it replaced."
)


def test_example(capture_mode):
    r = _run("06_example.php", stdin=FIXTURE_TEXT)
    assert_model_output_ok(r, min_chars=50)
    if capture_mode:
        capture_output("php", "06_example.php", r.stdout)
