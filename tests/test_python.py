"""Python language scripts - run each against live apfel --serve."""
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

PY_DIR = REPO_ROOT / "scripts" / "python"
UV_RUN = ["uv", "run", "--project", str(PY_DIR), "python"]


def _run(script: str, stdin: str | None = None):
    return run_script([*UV_RUN, str(script_path("python", script))], stdin=stdin)


def test_oneshot(capture_mode):
    r = _run("01_oneshot.py")
    assert_model_output_ok(r)
    if capture_mode:
        capture_output("python", "01_oneshot.py", r.stdout)


def test_stream(capture_mode):
    r = _run("02_stream.py")
    assert_model_output_ok(r)
    assert "\n" in r.stdout, "streaming should include newlines"
    if capture_mode:
        capture_output("python", "02_stream.py", r.stdout)


def test_json(capture_mode):
    r = _run("03_json.py")
    assert_model_output_ok(r)
    data = json.loads(r.stdout)
    assert isinstance(data, dict)
    if capture_mode:
        capture_output("python", "03_json.py", r.stdout)


def test_errors(capture_mode):
    r = _run("04_errors.py")
    assert_model_output_ok(r)
    assert "501" in r.stdout
    if capture_mode:
        capture_output("python", "04_errors.py", r.stdout)


def test_tools(capture_mode):
    r = run_until_weather_answer([*UV_RUN, str(script_path("python", "05_tools.py"))])
    assert_model_output_ok(r)
    assert any(w in r.stdout.lower() for w in WEATHER_KEYWORDS), r.stdout
    if capture_mode:
        capture_output("python", "05_tools.py", r.stdout)


FIXTURE_TEXT = (
    "The Apple M1 chip, released in November 2020, was Apple's first ARM-based "
    "system-on-a-chip for Mac computers. It uses an 8-core CPU with four performance "
    "and four efficiency cores, plus an integrated GPU with up to 8 cores. The chip "
    "unified CPU, GPU, memory, and neural engine on a single die, delivering significant "
    "performance-per-watt improvements over the Intel chips it replaced."
)


def test_example(capture_mode):
    r = _run("06_example.py", stdin=FIXTURE_TEXT)
    assert_model_output_ok(r, min_chars=50)
    if capture_mode:
        capture_output("python", "06_example.py", r.stdout)
