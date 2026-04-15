<?php
// JSON mode - request structured output and parse it.
require __DIR__ . "/vendor/autoload.php";

$client = OpenAI::factory()
    ->withBaseUri("http://localhost:11434/v1")
    ->withApiKey("not-needed")
    ->make();

$response = $client->chat()->create([
    "model" => "apple-foundationmodel",
    "messages" => [
        [
            "role" => "user",
            "content" => "Return JSON with fields 'chip', 'year', 'cores'. Describe the Apple M1 chip. Return ONLY JSON.",
        ],
    ],
    "response_format" => ["type" => "json_object"],
    "max_tokens" => 120,
]);

$raw = trim($response->choices[0]->message->content ?? "");
$raw = preg_replace('/\A```(?:json)?\s*|\s*```\z/m', "", $raw);
$data = json_decode(trim($raw), true, flags: JSON_THROW_ON_ERROR);
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n";
