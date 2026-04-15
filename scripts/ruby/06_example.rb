# Real-world mini example: summarize text from stdin in one paragraph.
require "openai"

text = $stdin.read.strip
if text.empty?
  warn "usage: cat file.txt | ruby 06_example.rb"
  exit 1
end

client = OpenAI::Client.new(
  uri_base: "http://localhost:11434",
  access_token: "not-needed"
)

response = client.chat(
  parameters: {
    model: "apple-foundationmodel",
    messages: [
      { role: "system", content: "You are a concise summarizer. Reply with one short paragraph." },
      { role: "user", content: "Summarize:\n\n#{text}" }
    ],
    max_tokens: 150
  }
)

puts response.dig("choices", 0, "message", "content").to_s.strip
