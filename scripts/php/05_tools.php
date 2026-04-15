<?php
// Tool calling - define a tool, let the model call it, return the result.
require __DIR__ . "/vendor/autoload.php";

$client = OpenAI::factory()
    ->withBaseUri("http://localhost:11434/v1")
    ->withApiKey("not-needed")
    ->make();

$tools = [[
    "type" => "function",
    "function" => [
        "name" => "get_weather",
        "description" => "Get the current temperature in Celsius for a city.",
        "parameters" => [
            "type" => "object",
            "properties" => ["city" => ["type" => "string", "description" => "City name"]],
            "required" => ["city"],
        ],
    ],
]];

function get_weather(array $args): string {
    $fake = ["Vienna" => 14, "Cupertino" => 19, "Tokyo" => 11];
    $city = $args["city"] ?? "";
    return json_encode(["city" => $city, "temp_c" => $fake[$city] ?? 15]);
}

$messages = [["role" => "user", "content" => "What is the temperature in Vienna right now?"]];

$first = $client->chat()->create([
    "model" => "apple-foundationmodel",
    "messages" => $messages,
    "tools" => $tools,
    "max_tokens" => 256,
]);

$msg = $first->choices[0]->message;
$messages[] = $msg->toArray();

if (!empty($msg->toolCalls)) {
    foreach ($msg->toolCalls as $call) {
        $args = json_decode($call->function->arguments, true) ?? [];
        $result = get_weather($args);
        $messages[] = ["role" => "tool", "tool_call_id" => $call->id, "content" => $result];
    }
    $final = $client->chat()->create([
        "model" => "apple-foundationmodel",
        "messages" => $messages,
        "max_tokens" => 120,
    ]);
    echo trim($final->choices[0]->message->content ?? "") . "\n";
} else {
    echo trim($msg->content ?? "") . "\n";
}
