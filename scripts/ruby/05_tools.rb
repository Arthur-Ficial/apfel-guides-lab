# Tool calling - define a tool, let the model call it, return the result.
require "openai"
require "json"

client = OpenAI::Client.new(
  uri_base: "http://localhost:11434",
  access_token: "not-needed"
)

TOOLS = [
  {
    type: "function",
    function: {
      name: "get_weather",
      description: "Get the current temperature in Celsius for a city.",
      parameters: {
        type: "object",
        properties: { city: { type: "string", description: "City name" } },
        required: ["city"]
      }
    }
  }
]

def get_weather(args)
  fake = { "Vienna" => 14, "Cupertino" => 19, "Tokyo" => 11 }
  { city: args["city"], temp_c: fake[args["city"]] || 15 }.to_json
end

messages = [{ role: "user", content: "What is the temperature in Vienna right now?" }]

first = client.chat(
  parameters: { model: "apple-foundationmodel", messages: messages, tools: TOOLS, max_tokens: 256 }
)

msg = first.dig("choices", 0, "message")
messages << msg

if msg["tool_calls"] && !msg["tool_calls"].empty?
  msg["tool_calls"].each do |call|
    args = JSON.parse(call.dig("function", "arguments"))
    result = get_weather(args)
    messages << { role: "tool", tool_call_id: call["id"], content: result }
  end

  final = client.chat(
    parameters: { model: "apple-foundationmodel", messages: messages, max_tokens: 120 }
  )
  puts final.dig("choices", 0, "message", "content").to_s.strip
else
  puts msg["content"].to_s.strip
end
