#!/usr/bin/env swift
// Streaming chat completion - print tokens as bytes arrive.
import Foundation

let body: [String: Any] = [
  "model": "apple-foundationmodel",
  "messages": [["role": "user", "content": "List three Apple silicon chips, one per line."]],
  "max_tokens": 80,
  "stream": true,
]
let url = URL(string: "http://localhost:11434/v1/chat/completions")!
var req = URLRequest(url: url)
req.httpMethod = "POST"
req.setValue("application/json", forHTTPHeaderField: "Content-Type")
req.httpBody = try JSONSerialization.data(withJSONObject: body)

let sem = DispatchSemaphore(value: 0)

Task {
  defer { sem.signal() }
  let (bytes, _) = try await URLSession.shared.bytes(for: req)
  for try await line in bytes.lines {
    var payload = line
    if payload.hasPrefix("data: ") { payload.removeFirst("data: ".count) }
    guard !payload.isEmpty, payload != "[DONE]" else { continue }
    guard let data = payload.data(using: .utf8),
          let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let choices = obj["choices"] as? [[String: Any]],
          let first = choices.first,
          let delta = first["delta"] as? [String: Any],
          let content = delta["content"] as? String
    else { continue }
    FileHandle.standardOutput.write(content.data(using: .utf8) ?? Data())
  }
  print()
}
sem.wait()
