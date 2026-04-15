<?php
// Real-world mini example: summarize text from stdin in one paragraph.
require __DIR__ . "/vendor/autoload.php";

$text = trim(stream_get_contents(STDIN));
if ($text === "") {
    fwrite(STDERR, "usage: cat file.txt | php 06_example.php\n");
    exit(1);
}

$client = OpenAI::factory()
    ->withBaseUri("http://localhost:11434/v1")
    ->withApiKey("not-needed")
    ->make();

$response = $client->chat()->create([
    "model" => "apple-foundationmodel",
    "messages" => [
        ["role" => "system", "content" => "You are a concise summarizer. Reply with one short paragraph."],
        ["role" => "user", "content" => "Summarize:\n\n$text"],
    ],
    "max_tokens" => 150,
]);

echo trim($response->choices[0]->message->content ?? "") . "\n";
