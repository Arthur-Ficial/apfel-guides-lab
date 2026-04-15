// Streaming chat completion - print tokens as they arrive.
import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:11434/v1", apiKey: "not-needed" });

const stream = await client.chat.completions.create({
  model: "apple-foundationmodel",
  messages: [{ role: "user", content: "List three Apple silicon chips, one per line." }],
  max_tokens: 80,
  stream: true,
});

for await (const chunk of stream) {
  if (!chunk.choices || chunk.choices.length === 0) continue;
  const delta = chunk.choices[0].delta?.content ?? "";
  process.stdout.write(delta);
}
process.stdout.write("\n");
