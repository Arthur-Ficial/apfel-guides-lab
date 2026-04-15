# One-shot chat completion against apfel --serve using ruby-openai.
require "openai"

client = OpenAI::Client.new(
  uri_base: "http://localhost:11434",
  access_token: "not-needed"
)

response = client.chat(
  parameters: {
    model: "apple-foundationmodel",
    messages: [{ role: "user", content: "In one sentence, what is the Swift programming language?" }],
    max_tokens: 80
  }
)

puts response.dig("choices", 0, "message", "content").strip
