# JSON mode - request structured output and parse it.
require "openai"
require "json"

client = OpenAI::Client.new(
  uri_base: "http://localhost:11434",
  access_token: "not-needed"
)

response = client.chat(
  parameters: {
    model: "apple-foundationmodel",
    messages: [
      { role: "user",
        content: "Return JSON with fields 'chip', 'year', 'cores'. Describe the Apple M1 chip. Return ONLY JSON." }
    ],
    response_format: { type: "json_object" },
    max_tokens: 120
  }
)

raw = response.dig("choices", 0, "message", "content").to_s.strip
raw = raw.sub(/\A```(?:json)?\s*/, "").sub(/\s*```\z/, "").strip
data = JSON.parse(raw)
puts JSON.pretty_generate(data)
