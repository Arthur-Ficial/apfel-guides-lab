"""Sanity check: harness boots apfel --serve and health returns 200."""
import requests


def test_health(apfel_url):
    r = requests.get(f"{apfel_url}/health", timeout=5)
    assert r.status_code == 200


def test_models(apfel_url):
    r = requests.get(f"{apfel_url}/v1/models", timeout=5)
    assert r.status_code == 200
    data = r.json()
    assert "data" in data
    assert len(data["data"]) >= 1


def test_chat_completion(apfel_url):
    r = requests.post(
        f"{apfel_url}/v1/chat/completions",
        json={
            "model": "apple-foundationmodel",
            "messages": [{"role": "user", "content": "Say hello in exactly three words."}],
            "max_tokens": 32,
        },
        timeout=60,
    )
    assert r.status_code == 200, r.text
    data = r.json()
    assert data["choices"][0]["message"]["content"].strip()
