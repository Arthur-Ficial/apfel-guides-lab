#!/usr/bin/env perl
# Real-world mini example: summarize text from stdin in one paragraph.
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

my $text = do { local $/; <STDIN> };
$text //= '';
$text =~ s/^\s+|\s+$//g;
unless (length $text) {
    die "usage: cat file.txt | perl 06_example.pl\n";
}

my $body = encode_json({
    model      => 'apple-foundationmodel',
    messages   => [
        { role => 'system', content => 'You are a concise summarizer. Reply with one short paragraph.' },
        { role => 'user',   content => "Summarize:\n\n$text" },
    ],
    max_tokens => 150,
});

my $res = HTTP::Tiny->new->request(
    POST => 'http://localhost:11434/v1/chat/completions',
    { headers => { 'Content-Type' => 'application/json' }, content => $body }
);
die "HTTP $res->{status}\n" unless $res->{success};

my $content = decode_json($res->{content})->{choices}[0]{message}{content} // '';
$content =~ s/^\s+|\s+$//g;
print "$content\n";
