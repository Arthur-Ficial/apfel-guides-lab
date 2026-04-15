<?php
// Error handling - catch apfel's honest 501 for unsupported endpoints.
require __DIR__ . "/vendor/autoload.php";

use OpenAI\Exceptions\ErrorException;

$client = OpenAI::factory()
    ->withBaseUri("http://localhost:11434/v1")
    ->withApiKey("not-needed")
    ->make();

try {
    $client->embeddings()->create([
        "model" => "apple-foundationmodel",
        "input" => "apfel runs 100% on-device.",
    ]);
} catch (ErrorException $e) {
    // apfel returns HTTP 501 for endpoints the on-device model does not support.
    echo "Got expected error (HTTP 501): {$e->getMessage()}\n";
} catch (Throwable $e) {
    echo "Got expected error: " . get_class($e) . " - {$e->getMessage()}\n";
}
