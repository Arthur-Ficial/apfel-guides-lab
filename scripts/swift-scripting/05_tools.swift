#!/usr/bin/env swift
// Tool calling - define a tool, let the model call it, answer, final response.
import Foundation

let tools: [[String: Any]] = [[
  "type": "function",
  "function": [
    "name": "get_weather",
    "description": "Get the current temperature in Celsius for a city.",
    "parameters": [
      "type": "object",
      "properties": ["city": ["type": "string", "description": "City name"]],
      "required": ["city"],
    ],
  ],
]]

func getWeather(city: String) -> String {
  let fake: [String: Int] = ["Vienna": 14, "Cupertino": 19, "Tokyo": 11]
  let temp = fake[city] ?? 15
  let obj: [String: Any] = ["city": city, "temp_c": temp]
  return String(data: try! JSONSerialization.data(withJSONObject: obj), encoding: .utf8)!
}

func postJSON(_ body: [String: Any]) throws -> [String: Any] {
  var req = URLRequest(url: URL(string: "http://localhost:11434/v1/chat/completions")!)
  req.httpMethod = "POST"
  req.setValue("application/json", forHTTPHeaderField: "Content-Type")
  req.httpBody = try JSONSerialization.data(withJSONObject: body)

  let sem = DispatchSemaphore(value: 0)
  var result: [String: Any] = [:]
  URLSession.shared.dataTask(with: req) { data, _, _ in
    defer { sem.signal() }
    if let data = data,
       let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
      result = obj
    }
  }.resume()
  sem.wait()
  return result
}

var messages: [[String: Any]] = [["role": "user", "content": "What is the temperature in Vienna right now?"]]

let first = try postJSON([
  "model": "apple-foundationmodel",
  "messages": messages,
  "tools": tools,
  "max_tokens": 256,
])

guard let choices = first["choices"] as? [[String: Any]],
      let msg = choices.first?["message"] as? [String: Any]
else { print("no response"); exit(1) }

messages.append(msg)

if let toolCalls = msg["tool_calls"] as? [[String: Any]], !toolCalls.isEmpty {
  for call in toolCalls {
    guard let fn = call["function"] as? [String: Any],
          let argsJSON = fn["arguments"] as? String,
          let id = call["id"] as? String,
          let argsData = argsJSON.data(using: .utf8),
          let args = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any],
          let city = args["city"] as? String
    else { continue }
    let result = getWeather(city: city)
    messages.append(["role": "tool", "tool_call_id": id, "content": result])
  }
  let final = try postJSON([
    "model": "apple-foundationmodel",
    "messages": messages,
    "max_tokens": 120,
  ])
  if let choices = final["choices"] as? [[String: Any]],
     let finalMsg = choices.first?["message"] as? [String: Any],
     let content = finalMsg["content"] as? String {
    print(content.trimmingCharacters(in: .whitespacesAndNewlines))
  }
} else if let content = msg["content"] as? String {
  print(content.trimmingCharacters(in: .whitespacesAndNewlines))
}
