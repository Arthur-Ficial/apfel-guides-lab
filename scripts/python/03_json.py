#!/usr/bin/env python3
"""JSON mode - request structured output and parse it."""
import json
import re

from openai import OpenAI

client = OpenAI(base_url="http://localhost:11434/v1", api_key="not-needed")

response = client.chat.completions.create(
    model="apple-foundationmodel",
    messages=[
        {
            "role": "user",
            "content": (
                "Return JSON with fields 'chip', 'year', 'cores'. "
                "Describe the Apple M1 chip. Return ONLY JSON."
            ),
        },
    ],
    response_format={"type": "json_object"},
    max_tokens=120,
)

raw = (response.choices[0].message.content or "").strip()
raw = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw, flags=re.MULTILINE).strip()
data = json.loads(raw)
print(json.dumps(data, indent=2, sort_keys=True))
