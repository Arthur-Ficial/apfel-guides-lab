# Error handling - catch apfel's honest 501 for unsupported endpoints.
require "openai"

client = OpenAI::Client.new(
  uri_base: "http://localhost:11434",
  access_token: "not-needed"
)

begin
  client.embeddings(
    parameters: {
      model: "apple-foundationmodel",
      input: "apfel runs 100% on-device."
    }
  )
rescue Faraday::Error => e
  status = e.response && e.response[:status]
  puts "Got expected error: HTTP #{status} - #{e.message}"
end
