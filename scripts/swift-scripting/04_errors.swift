#!/usr/bin/env swift
// Error handling - capture HTTP status code, print friendly message on >= 400.
import Foundation

let body: [String: Any] = [
  "model": "apple-foundationmodel",
  "input": "apfel runs 100% on-device.",
]
let url = URL(string: "http://localhost:11434/v1/embeddings")!
var req = URLRequest(url: url)
req.httpMethod = "POST"
req.setValue("application/json", forHTTPHeaderField: "Content-Type")
req.httpBody = try JSONSerialization.data(withJSONObject: body)

let sem = DispatchSemaphore(value: 0)
var result = ""

URLSession.shared.dataTask(with: req) { data, response, _ in
  defer { sem.signal() }
  guard let http = response as? HTTPURLResponse else { return }
  if http.statusCode >= 400 {
    var msg = "see response"
    if let data = data,
       let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let err = obj["error"] as? [String: Any],
       let m = err["message"] as? String {
      msg = m
    }
    result = "Got expected error: HTTP \(http.statusCode) - \(msg)"
  } else {
    result = "unexpected success: HTTP \(http.statusCode)"
  }
}.resume()
sem.wait()
print(result)
