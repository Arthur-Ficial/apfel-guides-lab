#!/usr/bin/env swift
// One-shot chat completion against apfel --serve using URLSession.
import Foundation

struct ChatRequest: Encodable {
  struct Message: Encodable { let role, content: String }
  let model: String
  let messages: [Message]
  let max_tokens: Int
}

struct ChatResponse: Decodable {
  struct Choice: Decodable { struct Msg: Decodable { let content: String? }; let message: Msg }
  let choices: [Choice]
}

let url = URL(string: "http://localhost:11434/v1/chat/completions")!
var req = URLRequest(url: url)
req.httpMethod = "POST"
req.setValue("application/json", forHTTPHeaderField: "Content-Type")
req.httpBody = try JSONEncoder().encode(ChatRequest(
  model: "apple-foundationmodel",
  messages: [.init(role: "user", content: "In one sentence, what is the Swift programming language?")],
  max_tokens: 80
))

let sem = DispatchSemaphore(value: 0)
var finalText = ""
URLSession.shared.dataTask(with: req) { data, _, err in
  defer { sem.signal() }
  guard let data = data, err == nil else { return }
  if let decoded = try? JSONDecoder().decode(ChatResponse.self, from: data),
     let text = decoded.choices.first?.message.content {
    finalText = text.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}.resume()
sem.wait()
print(finalText)
