#!/usr/bin/env python3
"""Error handling - catch apfel's honest 501 for unsupported endpoints."""
from openai import APIStatusError, OpenAI

client = OpenAI(base_url="http://localhost:11434/v1", api_key="not-needed")

try:
    client.embeddings.create(
        model="apple-foundationmodel",
        input="apfel runs 100% on-device.",
    )
except APIStatusError as e:
    print(f"Got expected error: HTTP {e.status_code} - {e.message}")
