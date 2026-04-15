// Real-world mini example: summarize text from stdin in one paragraph.
import OpenAI from "openai";

const text = await new Promise((resolve) => {
  let buf = "";
  process.stdin.setEncoding("utf8");
  process.stdin.on("data", (c) => (buf += c));
  process.stdin.on("end", () => resolve(buf.trim()));
});

if (!text) {
  console.error("usage: cat file.txt | node 06_example.mjs");
  process.exit(1);
}

const client = new OpenAI({ baseURL: "http://localhost:11434/v1", apiKey: "not-needed" });

const response = await client.chat.completions.create({
  model: "apple-foundationmodel",
  messages: [
    { role: "system", content: "You are a concise summarizer. Reply with one short paragraph." },
    { role: "user", content: `Summarize:\n\n${text}` },
  ],
  max_tokens: 150,
});

console.log((response.choices[0].message.content || "").trim());
