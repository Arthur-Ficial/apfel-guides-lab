#!/usr/bin/env python3
"""Streaming chat completion - tokens arrive as they are generated."""
import sys

from openai import OpenAI

client = OpenAI(base_url="http://localhost:11434/v1", api_key="not-needed")

stream = client.chat.completions.create(
    model="apple-foundationmodel",
    messages=[{"role": "user", "content": "List three Apple silicon chips, one per line."}],
    max_tokens=80,
    stream=True,
)

for chunk in stream:
    if not chunk.choices:
        continue
    delta = chunk.choices[0].delta.content or ""
    sys.stdout.write(delta)
    sys.stdout.flush()

print()
