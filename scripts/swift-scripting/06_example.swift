#!/usr/bin/env swift
// Real-world mini example: summarize text from stdin in one paragraph.
import Foundation

let stdin = FileHandle.standardInput.readDataToEndOfFile()
guard let text = String(data: stdin, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
      !text.isEmpty
else {
  FileHandle.standardError.write(Data("usage: cat file.txt | swift 06_example.swift\n".utf8))
  exit(1)
}

let body: [String: Any] = [
  "model": "apple-foundationmodel",
  "messages": [
    ["role": "system", "content": "You are a concise summarizer. Reply with one short paragraph."],
    ["role": "user", "content": "Summarize:\n\n\(text)"],
  ],
  "max_tokens": 150,
]
var req = URLRequest(url: URL(string: "http://localhost:11434/v1/chat/completions")!)
req.httpMethod = "POST"
req.setValue("application/json", forHTTPHeaderField: "Content-Type")
req.httpBody = try JSONSerialization.data(withJSONObject: body)

let sem = DispatchSemaphore(value: 0)
var output = ""
URLSession.shared.dataTask(with: req) { data, _, _ in
  defer { sem.signal() }
  guard let data = data,
        let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let choices = obj["choices"] as? [[String: Any]],
        let msg = choices.first?["message"] as? [String: Any],
        let content = msg["content"] as? String
  else { return }
  output = content.trimmingCharacters(in: .whitespacesAndNewlines)
}.resume()
sem.wait()
print(output)
