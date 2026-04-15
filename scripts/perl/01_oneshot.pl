#!/usr/bin/env perl
# One-shot chat completion via HTTP::Tiny + JSON::PP (both ship with macOS perl).
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

my $body = encode_json({
    model      => 'apple-foundationmodel',
    messages   => [{ role => 'user', content => 'In one sentence, what is the Swift programming language?' }],
    max_tokens => 80,
});

my $res = HTTP::Tiny->new->request(
    POST => 'http://localhost:11434/v1/chat/completions',
    { headers => { 'Content-Type' => 'application/json' }, content => $body }
);
die "HTTP $res->{status}: $res->{content}\n" unless $res->{success};

my $data = decode_json($res->{content});
my $text = $data->{choices}[0]{message}{content} // '';
$text =~ s/^\s+|\s+$//g;
print "$text\n";
