#!/usr/bin/env perl
# JSON mode - ask for JSON, strip markdown fences, pretty-print.
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

my $body = encode_json({
    model      => 'apple-foundationmodel',
    messages   => [{
        role    => 'user',
        content => "Return JSON with fields chip, year, cores. Describe the Apple M1 chip. Return ONLY JSON.",
    }],
    response_format => { type => 'json_object' },
    max_tokens      => 120,
});

my $res = HTTP::Tiny->new->request(
    POST => 'http://localhost:11434/v1/chat/completions',
    { headers => { 'Content-Type' => 'application/json' }, content => $body }
);
die "HTTP $res->{status}\n" unless $res->{success};

my $raw = decode_json($res->{content})->{choices}[0]{message}{content} // '';
$raw =~ s/^\s*```(?:json)?//; $raw =~ s/```\s*$//;
$raw =~ s/^\s+|\s+$//g;

my $parsed = decode_json($raw);
print JSON::PP->new->pretty->canonical->encode($parsed);
