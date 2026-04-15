// Error handling - catch apfel's honest 501 for unsupported endpoints.
import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:11434/v1", apiKey: "not-needed" });

try {
  await client.embeddings.create({
    model: "apple-foundationmodel",
    input: "apfel runs 100% on-device.",
  });
} catch (err) {
  if (err instanceof OpenAI.APIError) {
    console.log(`Got expected error: HTTP ${err.status} - ${err.message}`);
  } else {
    throw err;
  }
}
