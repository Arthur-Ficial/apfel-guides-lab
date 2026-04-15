#!/usr/bin/env python3
"""Real-world mini example: summarize text from stdin in one paragraph."""
import sys

from openai import OpenAI

text = sys.stdin.read().strip()
if not text:
    sys.exit("usage: cat file.txt | python 06_example.py")

client = OpenAI(base_url="http://localhost:11434/v1", api_key="not-needed")

response = client.chat.completions.create(
    model="apple-foundationmodel",
    messages=[
        {"role": "system", "content": "You are a concise summarizer. Reply with one short paragraph."},
        {"role": "user", "content": f"Summarize:\n\n{text}"},
    ],
    max_tokens=150,
)

print((response.choices[0].message.content or "").strip())
