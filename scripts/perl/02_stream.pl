#!/usr/bin/env perl
# Streaming chat completion via HTTP::Tiny's data_callback.
use strict;
use warnings;
use HTTP::Tiny;
use JSON::PP;

my $body = encode_json({
    model      => 'apple-foundationmodel',
    messages   => [{ role => 'user', content => 'List three Apple silicon chips, one per line.' }],
    max_tokens => 80,
    stream     => JSON::PP::true,
});

my $buf = '';
my $cb = sub {
    my ($chunk) = @_;
    $buf .= $chunk;
    while ($buf =~ s/^(.*?)\r?\n//) {
        my $line = $1;
        next if $line !~ s/^data:\s*//;
        next if $line eq '' || $line eq '[DONE]';
        my $obj = eval { decode_json($line) } or next;
        my $choices = $obj->{choices} // [];
        next unless @$choices;
        my $delta = $choices->[0]{delta}{content};
        if (defined $delta) {
            STDOUT->autoflush(1);
            print $delta;
        }
    }
};

HTTP::Tiny->new->request(
    POST => 'http://localhost:11434/v1/chat/completions',
    {
        headers       => { 'Content-Type' => 'application/json' },
        content       => $body,
        data_callback => $cb,
    }
);
print "\n";
