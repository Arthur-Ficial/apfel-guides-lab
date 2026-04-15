"""Bash/curl language scripts - run each against live apfel --serve."""
import json

from tests.helpers import (
    REPO_ROOT,
    WEATHER_KEYWORDS,
    assert_model_output_ok,
    capture_output,
    run_script,
    run_until_weather_answer,
    script_path,
)

SH_DIR = REPO_ROOT / "scripts" / "bash-curl"


def _run(script: str, stdin: str | None = None):
    return run_script(["bash", str(script_path("bash-curl", script))], cwd=SH_DIR, stdin=stdin)


def test_oneshot(capture_mode):
    r = _run("01_oneshot.sh")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("bash-curl", "01_oneshot.sh", r.stdout)


def test_stream(capture_mode):
    r = _run("02_stream.sh")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("bash-curl", "02_stream.sh", r.stdout)


def test_json(capture_mode):
    r = _run("03_json.sh")
    assert_model_output_ok(r)
    assert isinstance(json.loads(r.stdout), dict)
    if capture_mode:
        capture_output("bash-curl", "03_json.sh", r.stdout)


def test_errors(capture_mode):
    r = _run("04_errors.sh")
    assert_model_output_ok(r)
    assert "501" in r.stdout
    if capture_mode:
        capture_output("bash-curl", "04_errors.sh", r.stdout)


def test_tools(capture_mode):
    r = run_until_weather_answer(["bash", str(script_path("bash-curl", "05_tools.sh"))], cwd=SH_DIR)
    assert_model_output_ok(r)
    assert any(w in r.stdout.lower() for w in WEATHER_KEYWORDS), r.stdout
    if capture_mode:
        capture_output("bash-curl", "05_tools.sh", r.stdout)


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
        capture_output("bash-curl", "06_example.sh", r.stdout)
