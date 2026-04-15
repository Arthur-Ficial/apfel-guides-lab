# Streaming chat completion - tokens arrive as chunks.
require "openai"

client = OpenAI::Client.new(
  uri_base: "http://localhost:11434",
  access_token: "not-needed"
)

client.chat(
  parameters: {
    model: "apple-foundationmodel",
    messages: [{ role: "user", content: "List three Apple silicon chips, one per line." }],
    max_tokens: 80,
    stream: proc do |chunk, _bytesize|
      next if chunk.dig("choices").nil? || chunk["choices"].empty?
      piece = chunk.dig("choices", 0, "delta", "content")
      print piece if piece
      $stdout.flush
    end
  }
)

puts
