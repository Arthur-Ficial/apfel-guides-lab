#!/usr/bin/env python3
"""One-shot chat completion against apfel --serve using the openai SDK."""
from openai import OpenAI

client = OpenAI(base_url="http://localhost:11434/v1", api_key="not-needed")

response = client.chat.completions.create(
    model="apple-foundationmodel",
    messages=[
        {"role": "user", "content": "In one sentence, what is the Swift programming language?"},
    ],
    max_tokens=80,
)

print((response.choices[0].message.content or "").strip())
