<?php
// One-shot chat completion against apfel --serve using openai-php/client.
require __DIR__ . "/vendor/autoload.php";

$client = OpenAI::factory()
    ->withBaseUri("http://localhost:11434/v1")
    ->withApiKey("not-needed")
    ->make();

$response = $client->chat()->create([
    "model" => "apple-foundationmodel",
    "messages" => [
        ["role" => "user", "content" => "In one sentence, what is the Swift programming language?"],
    ],
    "max_tokens" => 80,
]);

echo trim($response->choices[0]->message->content ?? "") . "\n";
