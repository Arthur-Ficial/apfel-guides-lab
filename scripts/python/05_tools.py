#!/usr/bin/env python3
"""Tool calling - define a tool, let the model call it, return the result."""
import json

from openai import OpenAI

client = OpenAI(base_url="http://localhost:11434/v1", api_key="not-needed")

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get the current temperature in Celsius for a city.",
            "parameters": {
                "type": "object",
                "properties": {
                    "city": {"type": "string", "description": "City name"},
                },
                "required": ["city"],
            },
        },
    }
]


def get_weather(city: str, **_: object) -> str:
    fake = {"Vienna": 14, "Cupertino": 19, "Tokyo": 11}
    return json.dumps({"city": city, "temp_c": fake.get(city, 15)})


messages = [{"role": "user", "content": "What is the temperature in Vienna right now?"}]

first = client.chat.completions.create(
    model="apple-foundationmodel",
    messages=messages,
    tools=TOOLS,
    max_tokens=256,
)

msg = first.choices[0].message
messages.append(msg.model_dump(exclude_none=True))

if msg.tool_calls:
    for call in msg.tool_calls:
        args = json.loads(call.function.arguments)
        result = get_weather(**args)
        messages.append(
            {"role": "tool", "tool_call_id": call.id, "content": result}
        )

    final = client.chat.completions.create(
        model="apple-foundationmodel",
        messages=messages,
        max_tokens=120,
    )
    print((final.choices[0].message.content or "").strip())
else:
    print((msg.content or "").strip())
