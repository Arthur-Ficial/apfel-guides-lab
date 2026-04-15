// JSON mode - request structured output and parse it.
import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:11434/v1", apiKey: "not-needed" });

const response = await client.chat.completions.create({
  model: "apple-foundationmodel",
  messages: [
    {
      role: "user",
      content:
        "Return JSON with fields 'chip', 'year', 'cores'. " +
        "Describe the Apple M1 chip. Return ONLY JSON.",
    },
  ],
  response_format: { type: "json_object" },
  max_tokens: 120,
});

let raw = (response.choices[0].message.content || "").trim();
raw = raw.replace(/^```(?:json)?\s*|\s*```$/gm, "").trim();
const data = JSON.parse(raw);
console.log(JSON.stringify(data, null, 2));
