<?php
// Streaming chat completion - print tokens as they arrive.
require __DIR__ . "/vendor/autoload.php";

$client = OpenAI::factory()
    ->withBaseUri("http://localhost:11434/v1")
    ->withApiKey("not-needed")
    ->make();

$stream = $client->chat()->createStreamed([
    "model" => "apple-foundationmodel",
    "messages" => [["role" => "user", "content" => "List three Apple silicon chips, one per line."]],
    "max_tokens" => 80,
]);

foreach ($stream as $response) {
    if (empty($response->choices)) {
        continue;
    }
    $delta = $response->choices[0]->delta->content ?? "";
    echo $delta;
    flush();
}
echo "\n";
