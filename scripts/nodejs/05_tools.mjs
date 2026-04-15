// Tool calling - define a tool, let the model call it, return the result.
import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:11434/v1", apiKey: "not-needed" });

const tools = [
  {
    type: "function",
    function: {
      name: "get_weather",
      description: "Get the current temperature in Celsius for a city.",
      parameters: {
        type: "object",
        properties: {
          city: { type: "string", description: "City name" },
        },
        required: ["city"],
      },
    },
  },
];

function getWeather({ city }) {
  const fake = { Vienna: 14, Cupertino: 19, Tokyo: 11 };
  return JSON.stringify({ city, temp_c: fake[city] ?? 15 });
}

const messages = [{ role: "user", content: "What is the temperature in Vienna right now?" }];

const first = await client.chat.completions.create({
  model: "apple-foundationmodel",
  messages,
  tools,
  max_tokens: 256,
});

const msg = first.choices[0].message;
messages.push(msg);

if (msg.tool_calls?.length) {
  for (const call of msg.tool_calls) {
    const args = JSON.parse(call.function.arguments);
    const result = getWeather(args);
    messages.push({ role: "tool", tool_call_id: call.id, content: result });
  }
  const final = await client.chat.completions.create({
    model: "apple-foundationmodel",
    messages,
    max_tokens: 120,
  });
  console.log((final.choices[0].message.content || "").trim());
} else {
  console.log((msg.content || "").trim());
}
