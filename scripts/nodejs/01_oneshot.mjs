// One-shot chat completion against apfel --serve.
import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:11434/v1", apiKey: "not-needed" });

const response = await client.chat.completions.create({
  model: "apple-foundationmodel",
  messages: [{ role: "user", content: "In one sentence, what is the Swift programming language?" }],
  max_tokens: 80,
});

console.log((response.choices[0].message.content || "").trim());
