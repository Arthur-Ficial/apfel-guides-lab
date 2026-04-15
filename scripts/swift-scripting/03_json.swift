#!/usr/bin/env swift
// JSON mode - ask for a JSON object, strip markdown fences, pretty-print.
import Foundation

let body: [String: Any] = [
  "model": "apple-foundationmodel",
  "messages": [[
    "role": "user",
    "content": "Return JSON with fields chip, year, cores. Describe the Apple M1 chip. Return ONLY JSON.",
  ]],
  "response_format": ["type": "json_object"],
  "max_tokens": 120,
]
let url = URL(string: "http://localhost:11434/v1/chat/completions")!
var req = URLRequest(url: url)
req.httpMethod = "POST"
req.setValue("application/json", forHTTPHeaderField: "Content-Type")
req.httpBody = try JSONSerialization.data(withJSONObject: body)

let sem = DispatchSemaphore(value: 0)
var raw = ""

URLSession.shared.dataTask(with: req) { data, _, _ in
  defer { sem.signal() }
  guard let data = data,
        let top = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let choices = top["choices"] as? [[String: Any]],
        let msg = choices.first?["message"] as? [String: Any],
        let content = msg["content"] as? String
  else { return }
  raw = content
}.resume()
sem.wait()

var stripped = raw.trimmingCharacters(in: .whitespacesAndNewlines)
stripped = stripped.replacingOccurrences(of: "```json", with: "")
                   .replacingOccurrences(of: "```", with: "")
                   .trimmingCharacters(in: .whitespacesAndNewlines)

let parsed = try JSONSerialization.jsonObject(with: Data(stripped.utf8))
let pretty = try JSONSerialization.data(withJSONObject: parsed, options: [.prettyPrinted, .sortedKeys])
print(String(data: pretty, encoding: .utf8) ?? "")
